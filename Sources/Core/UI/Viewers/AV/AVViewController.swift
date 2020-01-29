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
    private var client: BoxClient?
    
    private lazy var titleView: CustomTitleView = {
        let view: CustomTitleView = CustomTitleView()
        return view
    }()
    
    public init(url: URL, title: String? = nil, client: BoxClient? = nil, actions: [FileInteractions]) {
        self.videoName = title
        self.AVPlayerVC = AVPlayerViewController()
        self.client = client
        super.init(nibName: nil, bundle: nil)
        // Not showing controls, so when video players doesn't flash a play button before it automatically starts playing
        self.AVPlayerVC.showsPlaybackControls = false
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
}

// MARK: - Setup video player

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
        titleView.title = videoName
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

    func set(actions actionTypes: [FileInteractions]) {
        var buttons: [UIBarButtonItem] = []

        if actionTypes.contains(.saveToFiles) {
            let button = makeSaveToFilesButton()
            button.action = #selector(saveButtonTapped(_:))
            buttons.append(button)
        }
        
        toolbarButtons = buttons
    }
}

// MARK: - Actions

private extension AVViewController {
    @objc func saveButtonTapped(_: Any) {
//        guard let fileData = document.dataRepresentation(),
//            let fileName = documentName else {
//                showAlertWith(title: "Error", message: "Unable to retrieve file data to perform save.")
//                return
//        }
//        do {
//            try saveDataToFiles(fileData, withName: fileName)
//            showAlertWith(title: "File saved", message: "The file was successfully saved.")
//        }
//        catch {
//            showAlertWith(title: "Error", message: "Unable to save file.")
//        }
        if client != nil {
            
        }
        FileManager.default.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
    }
}
