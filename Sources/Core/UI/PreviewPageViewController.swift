//
//  PreviewPageViewController.swift
//  BoxPreviewSDK-iOS
//
//  Created by Martina Stremeňová on 8/13/19.
//  Copyright © 2019 Box. All rights reserved.
//

import BoxSDK
import UIKit

public class PreviewPageViewController: UIViewController {

    private lazy var thumbnailViewController: ThumbnailHorizontalGridViewController = {
        let thumbnailHelper = ThumbnailPreviewHelper(client: helper.client, fileIds: helper.fileIds, imageIndex: helper.currentFileIdIndex)
        let thumbnailViewController = ThumbnailHorizontalGridViewController(thumbnailHelper: thumbnailHelper)
        thumbnailViewController.delegate = self
        return thumbnailViewController
    }()

    private lazy var thumbnailContainerView: UIView = {
        let containerView = UIView()
        return containerView
    }()

    private lazy var childViewControllerContainerView: UIView = {
        let containerView = UIView()
        return containerView
    }()

    private lazy var pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        return pageViewController
    }()

    private lazy var progressView: CustomProgressView = {
        let progressView = CustomProgressView()
        return progressView
    }()

    private lazy var errorView: ErrorView = {
        let errorView = self.previewDelegate?.makeCustomErrorView() ?? DefaultErrorView()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        return errorView
    }()

    private lazy var titleView: CustomTitleView = {
        let view: CustomTitleView = CustomTitleView()
        return view
    }()

    private lazy var thumbnailViewHeightConstraint: NSLayoutConstraint = {
        thumbnailContainerView.heightAnchor.constraint(equalToConstant: 80.0)
    }()

    private let helper: PreviewPagesHelper
    private let itemActions: [FileInteractions]
    private let displayThumbnails: Bool
    private weak var previewDelegate: PreviewViewControllerDelegate?
    private var viewControllers: [UIViewController?] = []

    // MARK: - Lifecycle

    public init(
        client: BoxClient,
        fileIds: [String],
        index: Int,
        delegate: PreviewViewControllerDelegate? = nil,
        allowedActions: [FileInteractions] = FileInteractions.allCases,
        customErrorView: ErrorView? = nil,
        displayThumbnails: Bool = false
    ) {
        helper = PreviewPagesHelper(client: client, fileIds: fileIds, selectedFileIndex: index)
        previewDelegate = delegate
        itemActions = allowedActions
        self.displayThumbnails = displayThumbnails
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        downloadFiles()
        setupView()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isToolbarHidden = true
    }

    @objc func galleryViewPressed() {
        let thumbnailGridViewController = ThumbnailGridViewController(helper: ThumbnailGridHelper(imageIds: helper.fileIds, client: helper.client),
                                                                      delegate: self)
        let navigationViewController = UINavigationController(rootViewController: thumbnailGridViewController)
        navigationController?.present(navigationViewController, animated: true, completion: nil)
    }
}

// MARK: - Thumbnail preview view delegate

extension PreviewPageViewController: ThumbnailGridViewControllerDelegate {
    func thumbnailGridViewController(_ thumbnailGridViewController: ThumbnailGridViewController, didSelectItemAt index: Int) {
        selectPage(at: index)
        thumbnailViewController.selectThumbnail(at: getCurrentIndex())
    }
}

extension PreviewPageViewController: ThumbnailHorizontalGridDelegate {
    func thumbnailPreview(_: ThumbnailHorizontalGridViewController, didSelectItemAtIndex index: Int) {
        selectPage(at: index)
    }
}

extension PreviewPageViewController: PreviewItemFullScreenDelegate {
    func viewController(_: UIViewController, didEnterFullScreen: Bool) {
        thumbnailViewHeightConstraint.constant = didEnterFullScreen ? 0 : 80
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

// MARK: - UIPageViewControllerDataSource & UIPageViewControllerDelegate

extension PreviewPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    public func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = getIndex(for: viewController)
        return getOrCreateViewController(at: currentIndex - 1)
    }

    public func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = getIndex(for: viewController)
        return getOrCreateViewController(at: currentIndex + 1)
    }

    public func pageViewController(_: UIPageViewController, didFinishAnimating _: Bool, previousViewControllers _: [UIViewController], transitionCompleted: Bool) {
        if transitionCompleted {
            let newCurrentIndex = getCurrentIndex()
            thumbnailViewController.selectThumbnail(at: getCurrentIndex())
            helper.currentFileIdIndex = newCurrentIndex
            updateNavigationItem()
        }
    }

    // MARK: - Paging helpers

    private func selectPage(at index: Int) {
        let currentIndex = getCurrentIndex()
        guard let newViewController = getOrCreateViewController(at: index) else {
            return
        }
        pageViewController.setViewControllers(
            [newViewController],
            direction: currentIndex < index ? .forward : .reverse,
            animated: true,
            completion: nil
        )
        helper.currentFileIdIndex = index
        updateNavigationItem()
    }

    private func getCurrentIndex() -> Int {
        guard let currentViewController = pageViewController.viewControllers?.first else {
            fatalError("PageViewController is empty.")
        }
        return getIndex(for: currentViewController)
    }

    private func getIndex(for viewController: UIViewController) -> Int {
        if let currentIndex = viewControllers.firstIndex(where: { controller in
            if controller == nil {
                return false
            }
            return controller == viewController
        }) {
            return currentIndex
        }

        fatalError("Could not find ViewController: \(viewController) in the list of viewcontrollers.")
    }

    private func getOrCreateViewController(at index: Int) -> UIViewController? {
        if !(0 ..< helper.fileIds.count).contains(index) {
            return nil
        }

        if let viewController = viewControllers[index] {
            return viewController
        }
        let viewController = PreviewViewController(client: helper.client, fileId: helper.fileIds[index], allowedActions: itemActions)
        viewController.shouldHideToolbarWhenDisappearing = false
        viewController.fullScreenDelegate = self
        viewController.parentWithToolbar = self
        viewControllers[index] = viewController
        return viewController
    }
}

// MARK: - Download helpers

private extension PreviewPageViewController {
    // Downloads file info for all of the files
    func downloadFiles() {
        addProgressView()
        helper.downloadFilesInfo(progress: { [weak self] progress in
            self?.progressView.setProgress(Double(progress.completedUnitCount))
        }, completion: { [weak self] result in
            guard let self = self else {
                return
            }
            self.removeProgressView()
            switch result {
            case .success:
                self.setUpChildrenViews()
            case let .failure(error):
                self.previewViewControllerFailed(error: BoxPreviewError(message: .contentSDKError, error: error))
            }
        })
    }
}

// MARK: - Layout set up helpers

private extension PreviewPageViewController {
    func updateNavigationItem() {
        guard let fileName = helper.files[helper.currentFileIdIndex]?.name else {
            return
        }
        titleView.title = fileName
        titleView.subtitle = "\(helper.currentFileIdIndex + 1) of \(helper.fileIds.count)"
    }

    func setUpNavigationItem() {
        if helper.fileIds.count > 1 {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "thumbnails", in: Bundle(for: type(of: self)), compatibleWith: nil),
                style: .plain, target: self, action: #selector(galleryViewPressed)
            )
        }
    }

    func setupView() {
        view.backgroundColor = .white
        navigationItem.titleView = titleView
        setUpNavigationItem()
    }

    func setUpChildrenViews() {
        if helper.fileIds.isEmpty {
            previewViewControllerFailed(error: BoxPreviewError(message: .unableToReadFile("No file id provided.")))
            return
        }

        // As SDK only supports preview for images, filter them out and ignore other files
        helper.extractImageFiles()
        // another check in case there's no file left after filtering out non-image files
        if helper.fileIds.isEmpty {
            previewViewControllerFailed(error: BoxPreviewError(message: .unableToFindImage))
            return
        }
        viewControllers = Array(repeating: nil, count: helper.fileIds.count)

        // add thumbnail
        if displayThumbnails {
            setupThumbnailView()
        }

        // prepare empty viewcontroller array to use later for reusing of controllers
        guard let currentViewController = getOrCreateViewController(at: helper.currentFileIdIndex) else {
            return
        }
        // add pageviewcontroller to view hierarchy
        addChild(childViewController: pageViewController)
        // display current page
        pageViewController.setViewControllers([currentViewController], direction: .forward, animated: true, completion: nil)
        thumbnailViewController.selectThumbnail(at: helper.currentFileIdIndex)
        updateNavigationItem()
    }

    func setupThumbnailView() {
        addThumnailContainerView()
        addChild(thumbnailViewController)
        thumbnailViewController.view.frame = thumbnailContainerView.bounds
        thumbnailContainerView.addSubview(thumbnailViewController.view)
        thumbnailViewController.didMove(toParent: self)
    }

    func addProgressView() {
        view.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: view.topAnchor),
            progressView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func removeProgressView() {
        DispatchQueue.main.async {
            self.progressView.removeFromSuperview()
        }
    }

    func addErrorView(with error: BoxPreviewError) {
        view.addSubview(errorView)
        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        errorView.displayError(error)
    }

    func removeErrorView() {
        DispatchQueue.main.async {
            self.errorView.removeFromSuperview()
        }
    }

    func addThumnailContainerView() {
        thumbnailContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(thumbnailContainerView)
        NSLayoutConstraint.activate([
            thumbnailViewHeightConstraint,
            thumbnailContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            thumbnailContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            thumbnailContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func addChildContainerView() {
        childViewControllerContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(childViewControllerContainerView)

        NSLayoutConstraint.activate([
            childViewControllerContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            childViewControllerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childViewControllerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childViewControllerContainerView.bottomAnchor.constraint(equalTo: displayThumbnails ?
                thumbnailContainerView.topAnchor :
                view.bottomAnchor
            )
        ])
    }

    func addChild(childViewController: UIViewController) {
        addChildContainerView()
        addChild(childViewController)
        childViewController.view.frame = childViewControllerContainerView.bounds
        childViewControllerContainerView.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
    }

    func previewViewControllerFailed(error: BoxPreviewError) {
        DispatchQueue.main.async { [weak self] in self?.addErrorView(with: error) }
        previewDelegate?.previewViewControllerFailed(error: error)
    }
}
