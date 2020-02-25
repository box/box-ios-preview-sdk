//
//  ImageViewController.swift
//  BOXPreviewSDK
//
//  Created on 11/9/18.
//  Copyright © 2018 Box Inc. All rights reserved.
//

import AVFoundation
import UIKit

public final class ImageViewController: UIViewController, PreviewItemChildViewController {

    // MARK: - Properties

    weak var fullScreenDelegate: PreviewItemFullScreenDelegate?

    private(set) var toolbarButtons: [UIBarButtonItem] = []

    private lazy var scrollView: ImageScrollView = {
        let scrollView = ImageScrollView(frame: view.frame)
        return scrollView
    }()

    private lazy var titleView: CustomTitleView = {
        let view: CustomTitleView = CustomTitleView()
        return view
    }()

    private lazy var singleTapGesture: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchTapped))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }()

    private var fileName: String?
    private var image: UIImage?

    private var fullScreenBackgroundColor: UIColor = .black
    private var defaultBackgroundColor: UIColor = .white
    private var isFullScreenOn: Bool {
        return view.backgroundColor == fullScreenBackgroundColor
    }

    // MARK: - Initializer

    public init(image: UIImage? = nil, title: String? = nil, actions: [FileInteractions]) {
        super.init(nibName: nil, bundle: nil)
        self.image = image
        fileName = title
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

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideFullScreenIfNeeded()
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        restoreStatesForRotation(in: size)
    }

    /// Takes an appropriate action based on the current action style
    @objc func touchTapped(_: UITapGestureRecognizer) {
        var shouldHide: Bool {
            guard let isNavigationBarHidden = navigationController?.isNavigationBarHidden else {
                return false
            }
            return !isNavigationBarHidden
        }
        fullScreenDelegate?.viewController(self, didEnterFullScreen: shouldHide)
        navigationController?.setNavigationBarHidden(shouldHide, animated: true)
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else {
                return
            }
            self.view.backgroundColor = shouldHide ? self.defaultBackgroundColor : self.fullScreenBackgroundColor
            self.navigationController?.isToolbarHidden = self.toolbarButtons.isEmpty ? true : !shouldHide
        }
    }

    // MARK: - PreviewItemChildViewController actions

    @objc func printButtonTapped(_: Any) {
        guard let image = image else {
            return
        }
        print(image)
    }

    @objc func saveButtonTapped(_: Any) {
        guard let image = image,
            let imageData = image.pngData(),
            let imageFileName = fileName else {
            showAlertWith(title: "Error", message: "Was not able to save the image due to missing data.")
            return
        }

        do {
            try saveDataToFiles(imageData, withName: imageFileName)
            showAlertWith(title: "Image saved", message: "Image was successfully saved to your files.")
        }
        catch {
            showAlertWith(title: "Error", message: "Was not able to save the image.")
        }
    }

    @objc func shareOptionsButtonTapped(_: Any) {
        guard let image = image,
        let fileName = fileName else {
            return
        }
        displayAllShareOptions(for: image, withName: fileName)
    }

    @objc func saveToLibraryButtonTapped(_: Any) {
        saveToLibrary()
    }
}

// MARK: - Image actions

private extension ImageViewController {

    func saveToLibrary() {
        guard let image = image else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func image(_: UIImage, didFinishSavingWithError error: Error?, contextInfo _: UnsafeRawPointer) {
        if let error = error {
            showAlertWith(title: "Error", message: error.localizedDescription)
        }
        else {
            showAlertWith(title: "Image saved", message: "Your image has been saved to your photos.")
        }
    }

    func copyToClipboard() {
        guard let image = image else {
            return
        }
        UIPasteboard.general.image = image
        showAlertWith(title: "Image copied", message: "Image was copied to the clipboard.")
    }
}

// MARK: - Private extensions

private extension ImageViewController {
    func setupView() {
        view.backgroundColor = .white
        setupImageScrollView()
        setupTitleView()
        view.addGestureRecognizer(singleTapGesture)
    }

    func setupImageScrollView() {
        guard let image = image else {
            return
        }
        view.addSubview(scrollView)
        scrollView.display(image)
    }

    func setupTitleView() {
        titleView.title = fileName
        parent?.navigationItem.titleView = titleView
    }

    func restoreStatesForRotation(in bounds: CGRect) {

        // recalculate contentSize based on current orientation
        let restorePoint = scrollView.pointToCenterAfterRotation()
        let restoreScale = scrollView.scaleToRestoreAfterRotation()
        scrollView.frame = bounds
        scrollView.setMaxMinZoomScaleForCurrentBounds()
        scrollView.restoreCenterPoint(to: restorePoint, oldScale: restoreScale)
    }

    func restoreStatesForRotation(in size: CGSize) {
        var bounds = view.bounds
        if bounds.size != size {
            bounds.size = size
            restoreStatesForRotation(in: bounds)
        }
    }


    func hideFullScreenIfNeeded() {
        if !isFullScreenOn {
            return
        }
        fullScreenDelegate?.viewController(self, didEnterFullScreen: false)
        navigationController?.setNavigationBarHidden(false, animated: true)
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else {
                return
            }
            self.view.backgroundColor = self.defaultBackgroundColor
            self.navigationController?.isToolbarHidden = self.toolbarButtons.isEmpty ? true : false
        }
    }

    func set(actions actionTypes: [FileInteractions]) {
        var buttons: [UIBarButtonItem] = []

        if actionTypes.contains(.allShareAndSaveActions) {
            let button = makeShareButton()
            button.action = #selector(shareOptionsButtonTapped(_:))
            buttons.append(button)
            toolbarButtons = buttons
            showAlertWith(title: "Error", message: "Was not able to save the image due to missing data.")
            return
        }

        if actionTypes.contains(.print) {
            let button = makePrintButton()
            button.action = #selector(printButtonTapped(_:))
            buttons.append(button)
        }

        if actionTypes.contains(.saveImageToLibrary) {
            let button = UIBarButtonItem(
                image: UIImage(named: "temp_save_image_library", in: Bundle(for: type(of: self)), compatibleWith: nil),
                style: .plain,
                target: self,
                action: #selector(saveToLibraryButtonTapped(_:))
            )
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

// MARK: - UIGestureRecognizerDelegate

extension ImageViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Don't recognize a single tap until a double-tap fails.
        if gestureRecognizer == singleTapGesture, otherGestureRecognizer == scrollView.zoomingTap {
            return true
        }
        return false
    }
}
