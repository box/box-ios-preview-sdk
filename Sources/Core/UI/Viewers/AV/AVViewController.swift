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

public class AVViewController: UIViewController, PreviewItemChildViewController {

    weak var fullScreenDelegate: PreviewItemFullScreenDelegate?
    var toolbarButtons: [UIBarButtonItem] = []
    
    private var videoName: String?
    private var AVPlayerVC: AVPlayerViewController
    
    private lazy var titleView: CustomTitleView = {
        let view: CustomTitleView = CustomTitleView()
        return view
    }()
    
    public init(url: URL, title: String? = nil, client: BoxClient? = nil, actions: [FileInteractions]) {
        self.videoName = title
        self.AVPlayerVC = AVPlayerViewController()
        self.AVPlayerVC.showsPlaybackControls = false
        super.init(nibName: nil, bundle: nil)
        self.set(actions: actions)
        self.setupPlayer(url: url, client: client)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            let navbarBottom = navigationController?.navigationBar.frame.maxY ?? CGFloat(0.0)
            let toolbarTop = navigationController?.toolbar.frame.minY ?? view.frame.maxY
//            print(navbarBottom)
//            print(toolbarTop)
//            self.AVPlayerVC?.view.frame = self.view.frame
        }
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
                        self.AVPlayerVC.player = AVPlayer(playerItem: playerItem)
                        self.AVPlayerVC.player?.play()
                        self.AVPlayerVC.showsPlaybackControls = true
                    }
                case .failure:
                    break
                }
            }
        }
        else {
            let asset = AVURLAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            DispatchQueue.main.async {
                self.AVPlayerVC.player = AVPlayer(playerItem: playerItem)
                self.AVPlayerVC.player?.play()
                self.AVPlayerVC.showsPlaybackControls = true
            }
        }
    }
}

// MARK: - Private extensions

private extension AVViewController {
    func setupView() {
        titleView.title = videoName
        parent?.navigationItem.titleView = titleView
        let navbarBottom = navigationController?.navigationBar.frame.maxY ?? CGFloat(0.0)
        let toolbarTop = navigationController?.toolbar.frame.minY ?? view.frame.maxY
        self.AVPlayerVC.view.frame = CGRect(x: 0.0, y: navbarBottom, width: self.view.frame.width, height: toolbarTop - navbarBottom)
        self.view.addSubview(self.AVPlayerVC.view ?? UIView())
//        NSLayoutConstraint.activate([
//            self.AVPlayerVC.view.topAnchor.constraint(equalTo: self.parent!.view.topAnchor),
//            self.AVPlayerVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            self.AVPlayerVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            self.AVPlayerVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
    }
    
    func set(actions actionTypes: [FileInteractions]) {
        var buttons: [UIBarButtonItem] = []

        if actionTypes.contains(.saveToFiles) {
            let button = makeSaveToFilesButton()
//            button.action = #selector(saveButtonTapped(_:))
            buttons.append(button)
        }
        
        toolbarButtons = buttons
    }
    
    // Gets a fresh token that will last for around an hour if the session allows for a new token
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
            delegatedSession.revokeTokens { revokeResult in
                switch revokeResult {
                case .success:
                    delegatedSession.getAccessToken { result in
                        switch result {
                        case let .success(accessToken):
                            completion(.success(accessToken))
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }
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
}
