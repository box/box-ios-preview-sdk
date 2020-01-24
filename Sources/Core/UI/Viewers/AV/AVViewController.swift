//
//  AVViewController.swift
//  BoxPreviewSDK-iOS
//
//  Created by Sujay Garlanka on 12/19/19.
//  Copyright © 2019 Box. All rights reserved.
//

import BoxSDK
import Foundation
import AVKit

public class AVViewController: AVPlayerViewController, PreviewItemChildViewController {

    weak var fullScreenDelegate: PreviewItemFullScreenDelegate?
    var toolbarButtons: [UIBarButtonItem] = []
    
    private var videoName: String?
    var gestureView: AVGestureView?
    
    private lazy var titleView: CustomTitleView = {
        let view: CustomTitleView = CustomTitleView()
        return view
    }()
    
    private lazy var singleTapGesture: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchTapped))
        gestureRecognizer.numberOfTapsRequired = 1
//        gestureRecognizer.delegate = self
        return gestureRecognizer
    }()
    
    public init(url: URL, title: String? = nil, client: BoxClient? = nil) {
        super.init(nibName: nil, bundle: nil)
        videoName = title
//        self.player = AVPlayer()
        setupPlayer(url: url, client: client)
//        log("test")
//        DispatchQueue.main.async {
//            self.gestureView = AVGestureView(frame: self.view.frame)
//        }
//        gestureView!.addGestureRecognizer(singleTapGesture)
//        self.contentOverlayView?.addSubview(gestureView!)
//        print("test")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    /// Takes an appropriate action based on the current action style
    @objc func touchTapped(_: UITapGestureRecognizer) {
//        titleView.title = "pressed"
//        parent?.navigationItem.titleView = titleView
//        showAlertWith(title: "Test", message: "Image was copied to the clipboard.")
//        var shouldHide: Bool {
//            guard let isNavigationBarHidden = navigationController?.isNavigationBarHidden else {
//                return false
//            }
//            return !isNavigationBarHidden
//        }
//        fullScreenDelegate?.viewController(self, didEnterFullScreen: shouldHide)
//        navigationController?.setNavigationBarHidden(true, animated: true)
//        UIView.animate(withDuration: 0.25) { [weak self] in
//            guard let self = self else {
//                return
//            }
//            self.navigationController?.isToolbarHidden = self.toolbarButtons.isEmpty ? true : !shouldHide
//        }
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension AVViewController {
    func setupPlayer(url: URL, client: BoxClient?) {
        if let unwrappedClient = client {
            self.getToken(client: unwrappedClient) { result in
                switch result {
                case let .success(accessToken):
                    let headers: [String: String] = [
                       "Authorization": "Bearer \(accessToken)"
                    ]
                    DispatchQueue.main.async {
                        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
                        let playerItem = AVPlayerItem(asset: asset)
                        self.player = AVPlayer(playerItem: playerItem)
                    }
//                        self.view.isUserInteractionEnabled = false
                case .failure:
                    DispatchQueue.main.async {
                        self.showAlertWith(title: "Error", message: "Was not able to retrview video.")
                    }
                }
            }
        }
        else {
            let asset = AVURLAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            self.player = AVPlayer(playerItem: playerItem)
        }
    }
    
    func getToken(client: BoxClient, completion: @escaping (Result<String, BoxSDKError>) -> Void) {
        if let oauthSession = client.session as? OAuth2Session {
            oauthSession.refreshToken { result in
                switch result {
                case let .success(accessToken):
                    completion(.success(accessToken))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
        else if let delegatedSession = client.session as? DelegatedAuthSession {
            
        }
        else if let singleTokenSession = client.session as? SingleTokenSession {
            singleTokenSession.getAccessToken { result in
                switch result {
                case let .success(accessToken):
                    completion(.success(accessToken))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func setupView() {
//        view.backgroundColor = .black
        titleView.title = videoName
//        self.showAlertWith(title: "Image copied", message: self.contentOverlayView!.frame.debugDescription)
        parent?.navigationItem.titleView = titleView
//        showAlertWith(title: "Image copied", message: "Image was copied to the clipboard.")
//        self.gestureView!.addGestureRecognizer(singleTapGesture)
    }
}

//extension VideoViewController: UIGestureRecognizerDelegate {
//    public func gestureRecognizer(
//        _ gestureRecognizer: UIGestureRecognizer,
//        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
//    ) -> Bool {
//        // Don't recognize a single tap until a double-tap fails.
//        if gestureRecognizer == singleTapGesture {
//            return true
//        }
//        return false
//    }
//}
