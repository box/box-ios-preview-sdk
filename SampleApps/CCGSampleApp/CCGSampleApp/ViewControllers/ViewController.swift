//
//  ViewController.swift
//  CCGSampleApp
//
//  Created by Artur Jankowski on 05/04/2022.
//  Copyright © 2022 Box. All rights reserved.
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
        setUpBoxSDK()
        setUpUI()
    }

    // MARK: - Actions

    @objc func loginButtonPressed() {
        removeErrorView()
        authorizeWithCCGClient()
    }
    
    @objc func logoutButtonPressed() {
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
    
    // MARK: - Set up

    private func setUpBoxSDK() {
        sdk = BoxSDK(
            clientId: Constants.clientId,
            clientSecret: Constants.clientSecret
        )
    }

    private func setUpUI() {
        title = "Box SDK - CCG Sample App"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(loginButtonPressed))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.tableFooterView = UIView()
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(getSinglePageOfFolderItems), for: .valueChanged)
        tableView.refreshControl = refresh
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
            showPreviewViewController(file: file)
        }
    }
}

// MARK: - CCG Helpers

private extension ViewController {
    func authorizeWithCCGClient() {
        tableView.refreshControl?.beginRefreshing()
        
        // Section 1 - CCG connection for account service

        #error("To obtain account service CCG connection please provide enterpriseId in Constants.swift file.")
        sdk.getCCGClientForAccountService(enterpriseId: Constants.enterpriseId, tokenStore: KeychainTokenStore()) { [weak self] result in
            self?.ccgAuthorizeHandler(result: result)
        }


        // Section 2 - CCG connection for user account

        #error("To obtain user account CCG connection please provide userId in Constants.swift file, comment out section 1 above and uncomment section 2.")
//        sdk.getCCGClientForUser(userId: Constants.userId, tokenStore: KeychainTokenStore()) { [weak self] result in
//            self?.ccgAuthorizeHandler(result: result)
//        }
    }
    
    func ccgAuthorizeHandler(result: Result<BoxClient, BoxSDKError>) {
        switch result {
        case let .success(client):
            self.client = client
            self.previewSDK = BoxPreviewSDK(client: client)
            getSinglePageOfFolderItems()
        case let .failure(error):
            print("error in getCCGClient: \(error)")
            self.addErrorView(with: error)
        }
    }
}
    
// MARK: - Loading items

extension ViewController {
    @objc func getSinglePageOfFolderItems() {
        let iterator = client.folders.listItems(
            folderId: BoxSDK.Constants.rootFolder,
            usemarker: true,
            fields: ["modified_at", "name", "extension"]
        )

        iterator.next { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(page):
                self.folderItems = []
                for (i, item) in page.entries.enumerated() {
                    print ("Item #\(String(format: "%03d", i + 1)) | \(item.debugDescription))")
                    DispatchQueue.main.async {
                        self.folderItems.append(item)
                        self.tableView.reloadData()
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(self.logoutButtonPressed))
                    }
                }
            case let .failure(error):
                print("error in getSinglePageOfFolderItems: \(error)")
                self.addErrorView(with: error)
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(self.logoutButtonPressed))
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    func showPreviewViewController(file: File) {
        let previewController: PreviewViewController? = previewSDK?.openFile(file: file, delegate: self)

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
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(self.loginButtonPressed))
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
