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

    // MARK: - Properties
    
    weak var fullScreenDelegate: PreviewItemFullScreenDelegate?
    var toolbarButtons: [UIBarButtonItem] = []
    
    private var url: URL
    private var file: File?
    private var AVPlayerVC: AVPlayerViewController
    private var client: BoxClient?
    
    private lazy var titleView: CustomTitleView = {
        let view: CustomTitleView = CustomTitleView()
        return view
    }()
    
    // MARK: - Initializer
    
    public init(url: URL, file: File? = nil, client: BoxClient? = nil, actions: [FileInteractions]) {
        self.url = url
        self.file = file
        self.AVPlayerVC = AVPlayerViewController()
        self.client = client
        super.init(nibName: nil, bundle: nil)
        // Not showing controls, so when video players doesn't flash a play button before it automatically starts playing
        self.AVPlayerVC.showsPlaybackControls = false
        self.setupPlayer()
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
}

// MARK: - Setup video player

private extension AVViewController {
    func setupPlayer() {
        if let unwrappedClient = client {
            self.getToken(client: unwrappedClient) { result in
                switch result {
                case let .success(accessToken):
                    let headers: [String: String] = [
                       "Authorization": "Bearer \(accessToken)"
                    ]
                    DispatchQueue.main.async {
                        // swiftlint:disable:next force_https
                        let asset = AVURLAsset(url: self.url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
                        let playerItem = AVPlayerItem(asset: asset)
                        self.AVPlayerVC.player = AVPlayer(playerItem: playerItem)
                        self.AVPlayerVC.player?.play()
                        self.AVPlayerVC.showsPlaybackControls = true
                    }
                case .failure:
                    DispatchQueue.main.async {
                        self.showAlertWith(title: "Error", message: "Unable to connect to Box account.")
                    }
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
    
    // Gets a fresh token that will last for around an hour if the session allows for a new token
    // swiftlint:disable cyclomatic_complexity
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
    // swiftlint:enable cyclomatic_complexity
}

// MARK: - Set up view

private extension AVViewController {
    func setupView() {
        titleView.title = file?.name
        parent?.navigationItem.titleView = titleView
        // This makes sure the video player is bounded by the navigation bar and toolbar and does not go below the two
        self.AVPlayerVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.AVPlayerVC.view)
        NSLayoutConstraint.activate([
            self.AVPlayerVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.AVPlayerVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            self.AVPlayerVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.AVPlayerVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
