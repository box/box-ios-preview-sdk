//
//  PDFViewController.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 6/27/19.
//  Copyright © 2019 Box. All rights reserved.
//

import PDFKit
import SafariServices
import UIKit

public class PDFViewController: UIViewController, PreviewItemChildViewController {
    
    // MARK: - Properties

    weak var fullScreenDelegate: PreviewItemFullScreenDelegate?
    private(set) var toolbarButtons: [UIBarButtonItem] = []
    
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var document: PDFDocument!
    private var documentName: String?
    private var pdfBackgroundColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0)
    private var shouldPreventAutoScale = false
    private var currentSearchResults: [PDFSelection] = []
    private var currentSelection: PDFSelection?
    
    /// Height of the thumbnail bar (used to hide/show)
    private lazy var pdfThumbnailViewHeightConstraint: NSLayoutConstraint = {
        let additionalHeight: CGFloat = self.toolbarButtons.isEmpty ?
            (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) : 0
        // setting insets to move pdfThumbnailView content above safe area when needed
        self.pdfThumbnailView.contentInset.bottom = additionalHeight
        return pdfThumbnailView.heightAnchor.constraint(equalToConstant: 60 + additionalHeight)
    }()
    
    /// Distance between the bottom thumbnail bar with bottom of page (used to hide/show)
    private lazy var pdfThumbnailContainerBottomConstraint: NSLayoutConstraint = {
        pdfThumbnailContainerView.bottomAnchor.constraint(
            equalTo:
            self.toolbarButtons.isEmpty ?
                view.bottomAnchor :
                view.safeAreaLayoutGuide.bottomAnchor
        )
    }()
    
    private lazy var singleTapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        tapGesture.require(toFail: doubleTapGesture)
        return tapGesture
    }()
    
    private lazy var doubleTapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_:)))
        tapGesture.numberOfTapsRequired = 2
        tapGesture.delegate = self
        return tapGesture
    }()
    
    // MARK: - Views
    
    private lazy var pdfView: PDFView = {
        var pdfView = PDFView(frame: self.view.frame)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.delegate = self
        pdfView.displayMode = .singlePage
        pdfView.backgroundColor = pdfBackgroundColor
        pdfView.autoScales = true
        pdfView.displayDirection = .vertical
        if let scrollView = pdfView.subviews.first as? UIScrollView {
            scrollView.contentInsetAdjustmentBehavior = .never
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        }
        return pdfView
    }()
    
    /* The pdfThumbnailContainerView solves an issue of pdfThumbnailView background color. In case of
     thumbnail view with no toolbar under it, it's constrained directly to the view, ignoring safe area.
     Therefore it's height is increased by safe area size and it's bottom insets are set to safe area size,
     so the thumbnails won't collide with bottom swipe functionality of iOS for devices with notch.
     However with this setup, an empty space is created between thumbnail and bottom of the screen,
     because pdfThumbnailView background color applies only to the collection view inside of it and not the
     whole view. This container view fills this space with white background. */
    private lazy var pdfThumbnailContainerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        return containerView
    }()
    
    private lazy var pdfThumbnailView: PDFThumbnailView = {
        var thumbnailView = PDFThumbnailView()
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.backgroundColor = .white
        thumbnailView.layoutMode = .horizontal
        thumbnailView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return thumbnailView
    }()
    
    private lazy var titleView: CustomTitleView = {
        let view: CustomTitleView = CustomTitleView()
        return view
    }()
    
    private lazy var searchResultsNavigationView: SearchNavigationView = {
        let view = SearchNavigationView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var searchResultsNavigationViewTopConstraint: NSLayoutConstraint = {
        return searchResultsNavigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -120)
    }()
    
    public init(document: PDFDocument, title: String? = nil, actions: [FileInteractions]) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
        documentName = title
        set(actions: actions)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !shouldPreventAutoScale else {
            return
        }
        pdfView.autoScales = true
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        pdfView.autoScales = true
        if UIDevice.current.orientation.isLandscape {
            pdfThumbnailViewHeightConstraint.constant = 44
        }
        else {
            pdfThumbnailViewHeightConstraint.constant = 60
        }
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    // MARK: - PreviewItemChildViewController actions
    
    @objc func printButtonTapped(_: Any) {
        if let fileData = document.dataRepresentation() {
            print(from: fileData)
        }
        else if let fileURL = document.documentURL {
            print(fileAt: fileURL)
        }
    }
    
    @objc func saveButtonTapped(_: Any) {
        guard let fileData = document.dataRepresentation(),
            let fileName = documentName else {
                showAlertWith(title: "Error", message: "Unable to retrieve file data to perform save.")
                return
        }
        do {
            try saveDataToFiles(fileData, withName: fileName)
            showAlertWith(title: "File saved", message: "The file was successfully saved.")
        }
        catch {
            showAlertWith(title: "Error", message: "Unable to save file.")
        }
    }
    
    @objc func shareOptionsButtonTapped(_: Any) {
        guard let fileData = document.dataRepresentation(),
            let documentName = documentName else {
                return
        }
        displayAllShareOptions(for: fileData, withName: documentName)
    }
}

// MARK: - Private helpers

private extension PDFViewController {
    func setupView() {
        view.addSubview(pdfView)
        view.addSubview(pdfThumbnailContainerView)
        view.addGestureRecognizer(singleTapGesture)
        setupPDFView()
        setupThumbnailView()
        setupTitleView()
        setupNavigationItems()
        setupGestureRecognizers()
        setupSearchResultsNavitionView()
        setupObservers()
        loadPDF()
        updatePageIndicator()
    }
    
    func setupPDFView() {
        view.backgroundColor = pdfBackgroundColor
    }
    
    func setupThumbnailView() {
        guard document.pageCount > 1 else {
            return
        }
        
        pdfThumbnailView.pdfView = pdfView
        pdfThumbnailView.thumbnailSize = CGSize(width: 24, height: 42)
        pdfThumbnailContainerView.addSubview(pdfThumbnailView)
        
        NSLayoutConstraint.activate([
            // container view to set the proper background color when working with safe area
            pdfThumbnailContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfThumbnailContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfThumbnailContainerBottomConstraint,
            // pdf thumbnail view
            pdfThumbnailViewHeightConstraint,
            pdfThumbnailView.topAnchor.constraint(equalTo: pdfThumbnailContainerView.topAnchor),
            pdfThumbnailView.leadingAnchor.constraint(equalTo: pdfThumbnailContainerView.leadingAnchor),
            pdfThumbnailView.trailingAnchor.constraint(equalTo: pdfThumbnailContainerView.trailingAnchor),
            pdfThumbnailView.bottomAnchor.constraint(equalTo: pdfThumbnailContainerView.bottomAnchor)
            ])
    }
    
    func setupTitleView() {
        titleView.title = documentName
        parent?.navigationItem.titleView = titleView
    }
    
    func setupNavigationItems() {
        var navBarItems: [UIBarButtonItem] = []
        if document.pageCount > 1 {
            navBarItems.append(UIBarButtonItem(
                image: UIImage(named: "thumbnails", in: Bundle(for: type(of: self)), compatibleWith: nil),
                style: .plain, target: self, action: #selector(galleryViewPressed)
            ))
        }
        
        let search = UIBarButtonItem(
            image: UIImage(named: "search", in: Bundle(for: type(of: self)), compatibleWith: nil),
            style: .plain, target: self, action: #selector(searchTapped)
        )
        
        navBarItems.append(search)
        
        parent?.navigationItem.rightBarButtonItems = navBarItems
        parent?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(PDFViewController.handlePageChange(notification:)),
            name: Notification.Name.PDFViewPageChanged,
            object: nil
        )
    }
    
    func loadPDF() {
        pdfView.document = document
        view.layoutIfNeeded()
        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
        pdfView.maxScaleFactor = 2.5
        pdfView.autoScales = true
    }
    
    func setupGestureRecognizers() {
        view.addGestureRecognizer(singleTapGesture)
        view.addGestureRecognizer(doubleTapGesture)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeLeft.direction = .left
        pdfView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeRight.direction = .right
        pdfView.addGestureRecognizer(swipeRight)
    }
    
    func setupSearchResultsNavitionView() {
        view.addSubview(searchResultsNavigationView)
        NSLayoutConstraint.activate([
            searchResultsNavigationView.heightAnchor.constraint(equalToConstant: 44),
            searchResultsNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchResultsNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchResultsNavigationViewTopConstraint
            ])
    }
    
    func set(actions actionTypes: [FileInteractions]) {
        var buttons: [UIBarButtonItem] = []
        
        if document.outlineRoot != nil {
            let button = UIBarButtonItem(
                image: UIImage(named: "outline", in: Bundle(for: type(of: self)), compatibleWith: nil),
                style: .plain,
                target: self,
                action: #selector(outlinePressed))
            buttons.append(button)
        }
        
        if actionTypes.contains(.allShareAndSaveActions) {
            let button = makeShareButton()
            button.action = #selector(shareOptionsButtonTapped(_:))
            buttons.append(button)
            toolbarButtons = buttons.reversed()
            return
        }
        
        if actionTypes.contains(.print) {
            let button = makePrintButton()
            button.action = #selector(printButtonTapped(_:))
            buttons.append(button)
        }
        
        if actionTypes.contains(.saveToFiles) {
            let button = makeSaveToFilesButton()
            button.action = #selector(saveButtonTapped(_:))
            buttons.append(button)
        }
        toolbarButtons = buttons
    }
}

// MARK: - Actions

extension PDFViewController {
    private func handleFullScreenMode(_ shouldDisplayFullScreenMode: Bool) {
        if shouldDisplayFullScreenMode {
            showFullScreenMode()
        }
        else {
            hideFullScreenMode()
        }
    }
    
    private func showFullScreenMode() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else {
                return
            }
            self.pdfThumbnailContainerBottomConstraint.constant = self.pdfThumbnailViewHeightConstraint.constant + 50
            self.hideSearchResultsView()
            self.pdfView.backgroundColor = .black
            self.view.backgroundColor = .black
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideFullScreenMode() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else {
                return
            }
            self.pdfThumbnailContainerBottomConstraint.constant = 0
            self.pdfView.backgroundColor = self.pdfBackgroundColor
            self.showSearchResultsView()
            self.view.backgroundColor = self.pdfBackgroundColor
            self.view.layoutIfNeeded()
        }
    }
    
    private func updatePageIndicator() {
        guard let currentPage = pdfView.currentPage else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                let titleView = self.parent?.navigationItem.titleView as? CustomTitleView else {
                    return
            }
            titleView.subtitleLabel.text = "Page \(self.document.index(for: currentPage) + 1) of \(self.document.pageCount)"
        }
    }
    
    // MARK: - Actions
    
    @objc func singleTapped(_: UITapGestureRecognizer) {
        var shouldHide: Bool {
            guard let isNavigationBarHidden = navigationController?.isNavigationBarHidden else {
                return false
            }
            return !isNavigationBarHidden
        }
        fullScreenDelegate?.viewController(self, didEnterFullScreen: shouldHide)
        UIView.animate(withDuration: 0.25) {
            self.handleFullScreenMode(shouldHide)
            self.navigationController?.isToolbarHidden = self.toolbarButtons.isEmpty ? true : shouldHide
        }
        navigationController?.setNavigationBarHidden(shouldHide, animated: true)
    }
    
    @objc func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            pdfView.goToPreviousPage(nil)
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            pdfView.goToNextPage(nil)
        }
    }
    
    @objc func galleryViewPressed() {
        let thumbnailGridViewController = ThumbnailGridViewController(helper: ThumbnailGridHelper(document: document),
                                                                      delegate: self)
        let navigationViewController = UINavigationController(rootViewController: thumbnailGridViewController)
        navigationController?.present(navigationViewController, animated: true, completion: nil)
    }
    
    @objc private func outlinePressed() {
        guard let outlineRoot = document.outlineRoot else {
            return
        }
        
        let outlineVC = OutlineViewController(outline: outlineRoot, delegate: self)
        let navVC = UINavigationController(rootViewController: outlineVC)
        navigationController?.present(navVC, animated: true, completion: nil)
    }
    
    @objc private func handlePageChange(notification _: Notification) {
        updatePageIndicator()
    }
    
    @objc private func searchTapped() {
        let searchViewController = SearchViewController(document: document, delegate: self)
        let navigationViewController = UINavigationController(rootViewController: searchViewController)
        removeHighlightFromSearchResults()
        hideSearchResultsView()
        navigationController?.present(navigationViewController, animated: true, completion: nil)
    }
}

// MARK: - ThumbnailGridViewControllerDelegate

extension PDFViewController: ThumbnailGridViewControllerDelegate {
    func thumbnailGridViewController(_ thumbnailGridViewController: ThumbnailGridViewController, didSelectItemAt index: Int) {
        if let page = document.page(at: index) {
            pdfView.go(to: page)
        }
    }
}

// MARK: - OutlineViewControllerDelegate

extension PDFViewController: OutlineViewControllerDelegate {
    func outlineViewController(_: OutlineViewController, didSelect page: PDFPage) {
        pdfView.go(to: page)
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - SearchViewController

extension PDFViewController: SearchViewControllerDelegate {
    func userDidTapOnSearchResult(selection: PDFSelection, searchResults: [PDFSelection]) {
        highlightSearchResults(selections: searchResults)
        currentSelection = selection
        zoomInToSelection(selection)
        hightlightCurrentSearchResult(selection)
        configureSearchResultsView(selection: selection, searchResults: searchResults)
        showSearchResultsView()
    }
    
    private func highlightSearchResults(selections: [PDFSelection]) {
        currentSearchResults = selections
        selections.forEach { selection in
            selection.pages.forEach { page in
                let highlight = PDFAnnotation(bounds: selection.bounds(for: page),
                                              forType: .highlight, withProperties: nil)
                highlight.endLineStyle = .square
                highlight.color = UIColor.yellow.withAlphaComponent(0.5)
                page.addAnnotation(highlight)
            }
        }
    }
    
    private func hightlightCurrentSearchResult(_ currentSelection: PDFSelection) {
        currentSelection.pages.forEach { page in
            page.annotations.forEach { annotation in
                if annotation.bounds == currentSelection.bounds(for: page) {
                    annotation.color = UIColor.orange.withAlphaComponent(0.5)
                } else {
                    annotation.color = UIColor.yellow.withAlphaComponent(0.5)
                }
            }
        }
    }
    
    private func removeHighlightFromSearchResults() {
        for index in 0..<document.pageCount {
            guard let page = document.page(at: index) else {
                return
            }
            page.annotations.forEach { page.removeAnnotation($0) }
        }
    }
    
    private func zoomInToSelection(_ selection: PDFSelection) {
        pdfView.go(to: selection)
        shouldPreventAutoScale = true
        scrollAndZoomToCurrentSelection()
    }
    
    private func scrollAndZoomToCurrentSelection() {
        guard let document = document, let currentSelection = currentSelection, let scrollView = pdfView.subviews.first as? UIScrollView,
            let pageLabel = currentSelection.pages[0].label,
            let pageIndex = Int(pageLabel), let pdfPage = document.page(at: pageIndex - 1) else {
                return
        }
        
        let cgRect = currentSelection.bounds(for: pdfPage)
        let bounds = pdfPage.bounds(for: .cropBox)
        let newPoint = CGPoint(x: cgRect.minX, y: bounds.size.height - cgRect.midY)
        scrollView.zoom(to: newPoint, animated: true, forceZoomInMax: true)
    }
}

// MARK: - PDFViewDelegate

extension PDFViewController: PDFViewDelegate {
    public func pdfViewWillClick(onLink _: PDFView, with url: URL) {
        let safaryVC = SFSafariViewController(url: url)
        present(safaryVC, animated: true, completion: nil)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension PDFViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view, let parentView = touchView.superview,
            parentView.isKind(of: SearchNavigationView.self) || touchView.isKind(of: UIButton.self) {
            return false
        }
        
        if gestureRecognizer == singleTapGesture,
            let touchView = touch.view,
            let parentView = touchView.superview,
            let innerParentView = parentView.superview,
            innerParentView.isKind(of: PDFThumbnailView.self) {
            
            return false
        }
        
        return true
    }
}

// MARK: - Double tap gesture related

extension PDFViewController {
    @objc func doubleTapped(_ sender: UITapGestureRecognizer) {
        guard let scrollView = pdfView.subviews.first as? UIScrollView, let currentPage = pdfView.currentPage else {
            return
        }
        shouldPreventAutoScale = true
        let locationInView = sender.location(in: sender.view)
        let bounds = currentPage.bounds(for: .cropBox)
        let locationInPDFPage = pdfView.convert(locationInView, to: currentPage)
        let newPoint = CGPoint(x: locationInPDFPage.x, y: bounds.size.height - locationInPDFPage.y)
        scrollView.zoom(to: newPoint, animated: true)
    }
}

// MARK: - SearchNavigationViewDelegate
extension PDFViewController: SearchNavigationViewDelegate {
    func nextPressed() {
        guard let currentSelection = currentSelection, let currentSelectionIndex = currentSearchResults.firstIndex(of: currentSelection) else {
            return
        }
        if let nextSelection = currentSearchResults[safe: currentSelectionIndex + 1] {
            go(to: nextSelection)
        } else if currentSelectionIndex == currentSearchResults.count - 1 {
            go(to: currentSearchResults[0])
        }
    }
    
    func previousPressed() {
        guard let currentSelection = currentSelection, let currentSelectionIndex = currentSearchResults.firstIndex(of: currentSelection) else {
                return
        }
        if let previousSelection = currentSearchResults[safe: currentSelectionIndex - 1] {
            go(to: previousSelection)
        } else if currentSelectionIndex == 0 {
            go(to: currentSearchResults[currentSearchResults.count-1])
        }
    }
    
    private func go(to pdfSelection: PDFSelection) {
        self.currentSelection = pdfSelection
        configureSearchResultsView(selection: pdfSelection, searchResults: currentSearchResults)
        pdfView.go(to: pdfSelection)
        hightlightCurrentSearchResult(pdfSelection)
        pdfSelection.color = UIColor.orange.withAlphaComponent(0.5)
        guard let document = document, let currentSelection = currentSelection, let scrollView = pdfView.subviews.first as? UIScrollView,
            let pageLabel = currentSelection.pages[0].label,
            let pageIndex = Int(pageLabel), let pdfPage = document.page(at: pageIndex - 1) else {
                return
        }
        let cgRect = currentSelection.bounds(for: pdfPage)
        let bounds = pdfPage.bounds(for: .cropBox)
        let x = cgRect.midX
        let y = bounds.size.height - cgRect.midY
        let newPoint = CGPoint(x: x, y: y)
        
        scrollView.move(to: newPoint, animated: true)
    }
    
    private func showSearchResultsView() {
        guard !currentSearchResults.isEmpty else {
            return
        }
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else {
                return
            }
            self.searchResultsNavigationViewTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideSearchResultsView() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else {
                return
            }
            self.searchResultsNavigationViewTopConstraint.constant = -120
            self.view.layoutIfNeeded()
        }
    }
    
    private func configureSearchResultsView(selection: PDFSelection, searchResults: [PDFSelection]) {
        guard let index = searchResults.firstIndex(of: selection) else {
            return
        }
        searchResultsNavigationView.configure(currentIndex: index, results: searchResults)
    }
}
