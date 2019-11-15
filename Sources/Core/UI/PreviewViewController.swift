//
//  BoxPreviewViewController.swift
//  BoxPreviewSDK-iOS
//
//  Created by Patrick Simon on 7/2/19.
//  Copyright © 2019 Box. All rights reserved.
//

import BoxSDK
import UIKit

// MARK: - Preview actions

public enum FileInteractions: CaseIterable {

    // MARK: - Image-only actions

    /// Saves image to image library
    case saveImageToLibrary

    // MARK: - Common actions

    /// Print image or PDF
    case print
    /// Saves file to file system
    case saveToFiles

    /// Allow all share and save actions that iOS offers including printing
    /// Automatically replaces print, saveToFiles and saveImageToLibrary actions
    case allShareAndSaveActions
}

// MARK: - PreviewViewControllerDelegate

public protocol PreviewViewControllerDelegate: class {
    func previewViewControllerFailed(error: BoxPreviewError)
    func makeCustomErrorView() -> ErrorView?
}

public class PreviewViewController: UIViewController {

    // MARK: - Properties

    var shouldHideToolbarWhenDisappearing: Bool = true

    weak var parentWithToolbar: UIViewController?
    weak var delegate: PreviewViewControllerDelegate?
    weak var fullScreenDelegate: PreviewItemFullScreenDelegate?
    private let itemActions: [FileInteractions]

    private lazy var progressView: CustomProgressView = {
        let progressView = CustomProgressView()
        return progressView
    }()

    private lazy var errorView: ErrorView = {
        let errorView = self.delegate?.makeCustomErrorView() ?? DefaultErrorView()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        return errorView
    }()

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var previewHelper: PreviewHelper!

    // MARK: - Inits

    public init(client: BoxClient,
                fileId: String,
                delegate: PreviewViewControllerDelegate? = nil,
                allowedActions: [FileInteractions] = FileInteractions.allCases) {
        previewHelper = PreviewHelper(client: client, fileId: fileId)
        self.delegate = delegate
        itemActions = allowedActions
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        downloadFile()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Sets toolbar items for a parent in case of paging
        // Needs to be set every time view appears or otherwise parent will remain with old items in a toolbar.
        if !itemActions.isEmpty {
            navigationController?.isToolbarHidden = false
            parentWithToolbar?.toolbarItems = toolbarItems
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if shouldHideToolbarWhenDisappearing {
            navigationController?.isToolbarHidden = true
        }
    }

    public override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }

    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }

    public override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    public override var childForHomeIndicatorAutoHidden: UIViewController? {
        return nil
    }
}

// MARK: - Private helpers

private extension PreviewViewController {
    func setupView() {
        view.backgroundColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        addProgressView()
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

    func downloadFile() {
        previewHelper.downloadBoxFile(
            completion: { [weak self] result in
                guard let self = self else {
                    return
                }
                switch result {
                case .success:
                    self.removeProgressView()
                    let result = self.previewHelper.getChildViewController(withActions: self.itemActions)
                    switch result {
                    case let .success(childViewController):
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else {
                                return
                            }
                            self.displayChild(contentController: childViewController, on: self.view)
                        }
                    case let .failure(getChildViewControllerError):
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else {
                                return
                            }
                            self.previewViewControllerFailed(error: getChildViewControllerError)
                        }
                    }
                case let .failure(downloadFileError):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else {
                            return
                        }
                        self.removeProgressView()
                        self.previewViewControllerFailed(error: BoxPreviewError(message: .contentSDKError, error: downloadFileError))
                    }
                }
            }
        )
    }

    func displayChild(contentController content: UIViewController, on view: UIView) {
        addChild(content)
        content.view.frame = view.bounds
        view.addSubview(content.view)
        content.didMove(toParent: self)

        if let itemViewController = content as? PreviewItemChildViewController {
            itemViewController.fullScreenDelegate = fullScreenDelegate
            setToolbar(for: itemViewController)
        }
    }

    func setToolbar(for itemViewController: PreviewItemChildViewController) {
        navigationController?.isToolbarHidden = itemViewController.toolbarButtons.isEmpty
        toolbarItems = createToolbarItems(for: itemViewController)
        parentWithToolbar?.toolbarItems = toolbarItems
    }
    
    private func createToolbarItems(for itemViewController: PreviewItemChildViewController) -> [UIBarButtonItem] {
        var toolbarItems: [UIBarButtonItem] = []
        itemViewController.toolbarButtons.enumerated().forEach { index, item in
            if index == itemViewController.toolbarButtons.count - 1 {
                toolbarItems.append(item)
            } else {
                toolbarItems.append(contentsOf: [item, itemViewController.makeFlexiSpace()])
            }
        }
        return toolbarItems
    }

    func previewViewControllerFailed(error: BoxPreviewError) {
        DispatchQueue.main.async { [weak self] in self?.addErrorView(with: error) }
        delegate?.previewViewControllerFailed(error: error)
    }
}
