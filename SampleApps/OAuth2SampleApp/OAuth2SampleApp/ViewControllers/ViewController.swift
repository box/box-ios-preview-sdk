//
//  ViewController.swift
//  iOSSwiftExample
//
//  Created by Abel Osorio on 3/13/19.
//  Copyright © 2019 Box Inc. All rights reserved.
//

#if os(iOS)
    import AuthenticationServices
#endif
import BoxPreviewSDK
import BoxSDK
import UIKit

class ViewController: UITableViewController, ASWebAuthenticationPresentationContextProviding {

    private var sdk: BoxSDK!
    private var client: BoxClient!
    private var previewSDK: BoxPreviewSDK?
    private var folderItems: [FolderItem] = []
    private let initialPageSize: Int = 100

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy at HH:mm a"
        return formatter
    }()

    private lazy var errorView: BasicErrorView = {
        let errorView = BasicErrorView()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        return errorView
    }()

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Box Preview SDK - OAuth Sample App"
        sdk = BoxSDK(clientId: Constants.clientId, clientSecret: Constants.clientSecret)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(loginPressed))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.tableFooterView = UIView()
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(getSinglePageOfFolderItems), for: .valueChanged)
        tableView.refreshControl = refresh
    }

    // MARK: - Actions

    @objc func loginPressed() {
        removeErrorView()
        getOAuthClient()
    }
    
    @objc func logoutPressed() {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.logout()
        }
        
        let action2 = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return folderItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath)
        let item = folderItems[indexPath.row]
        if case let .file(file) = item {
            cell.textLabel?.text = file.name
            cell.detailTextLabel?.text = String(format: "Date Modified %@", dateFormatter.string(from: file.modifiedAt ?? Date()))
            cell.accessoryType = .none
            var icon: String
            switch file.extension {
            case "boxnote":
                icon = "boxnote"
            case "jpg",
                 "jpeg",
                 "png",
                 "tiff",
                 "tif",
                 "gif",
                 "bmp",
                 "BMPf",
                 "ico",
                 "cur",
                 "xbm":
                icon = "image"
            case "pdf":
                icon = "pdf"
            case "docx":
                icon = "word"
            case "pptx":
                icon = "powerpoint"
            case "xlsx":
                icon = "excel"
            case "zip":
                icon = "zip"
            default:
                icon = "generic"
            }
            cell.imageView?.image = UIImage(named: icon)
        }
        else if case let .folder(folder) = item {
            cell.textLabel?.text = folder.name
            cell.detailTextLabel?.text = ""
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.image = UIImage(named: "folder")
        }

        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = folderItems[indexPath.row]
        if case let .file(file) = item {
            showPreviewViewController(fileId: file.id)
        }
    }
}

// MARK: - Helpers

private extension ViewController {
    func getOAuthClient() {
        tableView.refreshControl?.beginRefreshing()
        if #available(iOS 13, *) {
            sdk.getOAuth2Client(tokenStore: KeychainTokenStore(), context:self) { [weak self] result in
                switch result {
                case let .success(client):
                    self?.client = client
                    self?.previewSDK = BoxPreviewSDK(client: client)
                    self?.getSinglePageOfFolderItems()
                case let .failure(error):
                    print("error in getOAuth2Client: \(error)")
                    self?.addErrorView(with: error)
                }
            }
        } else {
            sdk.getOAuth2Client(tokenStore: KeychainTokenStore()) { [weak self] result in
                switch result {
                case let .success(client):
                    self?.client = client
                    self?.previewSDK = BoxPreviewSDK(client: client)
                    self?.getSinglePageOfFolderItems()
                case let .failure(error):
                    print("error in getOAuth2Client: \(error)")
                    self?.addErrorView(with: error)
                }
            }
        }
    }

    @objc func getSinglePageOfFolderItems() {
        client.folders.listItems(
            folderId: BoxSDK.Constants.rootFolder,
            usemarker: true,
            fields: ["modified_at", "name", "extension"]
        ){ [weak self] result in
            guard let self = self else {return}

            switch result {
            case let .success(items):
                self.folderItems = []

                for i in 1...self.initialPageSize {
                    print ("Request Item #\(String(format: "%03d", i)) |")
                    items.next { result in
                        switch result {
                        case let .success(item):
                            print ("    Got Item #\(String(format: "%03d", i)) | \(item.debugDescription))")
                            DispatchQueue.main.async {
                                self.folderItems.append(item)
                                self.tableView.reloadData()
                                self.navigationItem.rightBarButtonItem?.title = "Refresh"
                            }
                        case let .failure(error):
                            print ("     No Item #\(String(format: "%03d", i)) | \(error.message)")
                            return
                        }
                    }
                }
            case let .failure(error):
                print("error in getSinglePageOfFolderItems: \(error)")
                self.addErrorView(with: error)
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(self.logoutPressed))
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    func showPreviewViewController(fileId: String) {
        let previewController: PreviewViewController? = previewSDK?.openFile(fileId: fileId, delegate: self)

        guard let unwrappedPreviewController = previewController else {
            return
        }

        navigationController?.pushViewController(unwrappedPreviewController, animated: true)
    }
    
    func logout() {
        tableView.refreshControl?.beginRefreshing()
        client.destroy { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.folderItems.removeAll()
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(self.loginPressed))
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            case let .failure(error):
                print(error)
            }
        }
    }
}

extension ViewController: PreviewViewControllerDelegate {

    func previewViewControllerFailed(error: BoxPreviewError) {
        print("Error returned by PreviewViewController: \(error)")
    }

    func makeCustomErrorView() -> ErrorView? {
        // Create custom error view here
        return nil
    }
}

private extension ViewController {

    func addErrorView(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view.addSubview(self.errorView)
            let safeAreaLayoutGuide = self.view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                self.errorView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                self.errorView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                self.errorView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                self.errorView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
                ])
            self.errorView.displayError(error)
        }
    }

    func removeErrorView() {
        if !view.subviews.contains(errorView) {
            return
        }
        DispatchQueue.main.async {
            self.errorView.removeFromSuperview()
        }
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

/// Extension for ASWebAuthenticationPresentationContextProviding conformance
extension ViewController {
    @available(iOS 13.0, *)
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}
