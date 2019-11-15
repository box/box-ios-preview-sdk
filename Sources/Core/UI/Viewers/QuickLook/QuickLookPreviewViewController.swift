//
//  QuickLookPreviewViewController.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 7/2/19.
//  Copyright © 2019 Box. All rights reserved.
//

import QuickLook
import UIKit

public class QuickLookPreviewViewController: UIViewController {

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var fileURL: URL!
    private lazy var previewController: QLPreviewController = {
        let controller = QLPreviewController()
        controller.dataSource = self
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        return controller
    }()

    public init(fileURL: URL, title: String? = nil) {
        self.fileURL = fileURL
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - View Life cycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

// MARK: - Private helpers

private extension QuickLookPreviewViewController {
    func setupView() {
        setupQLPreviewController()
        setupAppearance()
    }

    func setupAppearance() {
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
    }

    func setupQLPreviewController() {
        addChild(previewController)
        view.addSubview(previewController.view)
        NSLayoutConstraint.activate([
            previewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            previewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            previewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            previewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        previewController.view.didMoveToSuperview()
    }
}

// MARK: - QLPreviewControllerDataSource

extension QuickLookPreviewViewController: QLPreviewControllerDataSource {
    public func numberOfPreviewItems(in _: QLPreviewController) -> Int {
        return 1
    }

    public func previewController(_: QLPreviewController, previewItemAt _: Int) -> QLPreviewItem {
        return fileURL as QLPreviewItem
    }
}
