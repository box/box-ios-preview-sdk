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
    
    private lazy var progressView: CustomProgressView = {
        let progressView = CustomProgressView()
        return progressView
    }()
    
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
        self.set(actions: actions)
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

    func set(actions actionTypes: [FileInteractions]) {
        var buttons: [UIBarButtonItem] = []

        if actionTypes.contains(.allShareAndSaveActions) {
            let button = makeShareButton()
            button.action = #selector(shareOptionsButtonTapped(_:))
            buttons.append(button)
            toolbarButtons = buttons
            return
        }
        
        if actionTypes.contains(.saveToFiles) {
            let button = makeSaveToFilesButton()
            button.action = #selector(saveButtonTapped(_:))
            buttons.append(button)
        }
        
        toolbarButtons = buttons
    }
    
    func presentProgressView() -> UIAlertController {
        let alert = UIAlertController(title: "Downloading", message: "0%", preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Cancel", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(closeAction)
        alert.view.addSubview(progressView)
        
        progressView.removePercentageLabel()
        progressView.isUserInteractionEnabled = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: alert.view.topAnchor),
            progressView.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor)
        ])
        present(alert, animated: true, completion: nil)
        return alert
    }
}

// MARK: - Actions

private extension AVViewController {
    @objc func shareOptionsButtonTapped(_: Any) {
        if let unwrappedClient = client, let unwrappedFile = file {
            let filesDirectory = FileManager.default.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
            guard let filePath = filesDirectory.first else {
                showAlertWith(title: "Error", message: "Unable to open share options")
                return
            }
            let fileURL = filePath.appendingPathComponent(unwrappedFile.name ?? "untitled")
            let alertProgress = presentProgressView()
            unwrappedClient.files.download(fileId: unwrappedFile.id, destinationURL: fileURL, progress: { [weak self] progress in
                DispatchQueue.main.async {
                    alertProgress.message = "\(Int(progress.fractionCompleted * 100))%"
                    self?.progressView.setProgress(progress.fractionCompleted)
                }
            }) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        if self.presentedViewController != nil {
                            alertProgress.dismiss(animated: true, completion: nil)
                            self.displayAllShareOptions(filePath: fileURL)
                        }
                    case .failure:
                        if self.presentedViewController != nil {
                            alertProgress.dismiss(animated: true, completion: nil)
                            self.showAlertWith(title: "Error", message: "Unable to open share options")
                        }
                    }
                    self.progressView.setProgress(0.0)
                }
            }
        }
        else {
            self.displayAllShareOptions(filePath: url)
        }
    }
    
    @objc func saveButtonTapped(_: Any) {
        if let unwrappedClient = client, let unwrappedFile = file {
            let filesDirectory = FileManager.default.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
            guard let filePath = filesDirectory.first else {
                showAlertWith(title: "Error", message: "Unable to save media")
                return
            }
            unwrappedClient.files.download(fileId: unwrappedFile.id, destinationURL: filePath) { result in
                switch result {
                case .success:
                    self.showAlertWith(title: "Media saved", message: "Media was successfully saved to your files")
                case .failure:
                    self.showAlertWith(title: "Error", message: "Unable to save media")
                }
            }
        } else {
            self.showAlertWith(title: "Media saved", message: "Media was successfully saved to your files")
        }
    }
}
