//
//  VideoViewController.swift
//  BoxPreviewSDK-iOS
//
//  Created by Sujay Garlanka on 12/19/19.
//  Copyright © 2019 Box. All rights reserved.
//

import BoxSDK
import Foundation
import AVKit

public class VideoViewController: AVPlayerViewController, PreviewItemChildViewController {
    
    weak var fullScreenDelegate: PreviewItemFullScreenDelegate?
    var toolbarButtons: [UIBarButtonItem] = []
    
    private var videoName: String?
    
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
    
    public init(url: URL, title: String? = nil, client: BoxClient? = nil) {
        super.init(nibName: nil, bundle: nil)
        videoName = title
//        self.player = AVPlayer()
        setupPlayer(url: url, client: client)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
        navigationController?.setNavigationBarHidden(true, animated: true)
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else {
                return
            }
            self.navigationController?.isToolbarHidden = self.toolbarButtons.isEmpty ? true : !shouldHide
        }
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension VideoViewController {
    func setupPlayer(url: URL, client: BoxClient?) {
        if let unwrappedClient = client {
//            unwrappedClient.session.revokeTokens { _ in
                unwrappedClient.session.getAccessToken { result in
                    switch result {
                    case let .success(accessToken):
                        let headers: [String: String] = [
                           "Authorization": "Bearer \(accessToken)"
                        ]
                        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
                        let playerItem = AVPlayerItem(asset: asset)
                        self.player = AVPlayer(playerItem: playerItem)
                    case .failure:
                        self.showAlertWith(title: "Error", message: "Was not able connect to Box account.")
                    }
                }
//            }
        }
        else {
            let asset = AVURLAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            self.player = AVPlayer(playerItem: playerItem)
        }
    }
    func setupView() {
        titleView.title = videoName
        parent?.navigationItem.titleView = titleView
        view.addGestureRecognizer(singleTapGesture)
    }
}

extension VideoViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Don't recognize a single tap until a double-tap fails.
        if gestureRecognizer == singleTapGesture {
            return true
        }
        return false
    }
}
