//
//  SampleViewController.swift
//  BoxPreviewSampleApp
//
//  Created by Abel Osorio on 7/30/19.
//  Copyright © 2019 Box. All rights reserved.
//

import BoxPreviewSDK
import BoxSDK
import UIKit

class ViewController: UITableViewController {

    private var contentSDK: BoxSDK!
    private var client: BoxClient!
    private var previewSDK: BoxPreviewSDK!
    private var folderItems: [FolderItem] = []
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy at HH:mm a"
        return formatter
    }()

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Box Preview SDK - Sample App"
        setupView()
        contentSDK = BoxSDK(clientId: "", clientSecret: "")
        #error("Obtain a Developer Token for your app in the Box Developer Console at https://app.box.com/developers/console")
        client = contentSDK.getClient(token: "")
        previewSDK = BoxPreviewSDK(client: client)
        getSinglePageOfFolderItems()
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
        }
        else if case let .folder(folder) = item {
            cell.textLabel?.text = folder.name
            cell.detailTextLabel?.text = ""
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.image = UIImage(named: "folderIcon")
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

// MARK: - Helpers

private extension ViewController {

    private func setupView() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.tableFooterView = UIView()
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(getSinglePageOfFolderItems), for: .valueChanged)
        tableView.refreshControl = refresh
    }

    @objc func getSinglePageOfFolderItems() {
        let iterator = client.folders.listItems(
            folderId: BoxSDK.Constants.rootFolder,
            usemarker: true,
            fields: ["modified_at", "name"]
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
                        self.navigationItem.rightBarButtonItem = nil
                    }
                }
            case let .failure(error):
                print (error)
            }

            DispatchQueue.main.async { [weak self] in
                self?.navigationItem.rightBarButtonItem = nil
                self?.tableView.refreshControl?.endRefreshing()
                self?.tableView.reloadData()
            }
        }
    }

    func showPreviewViewController(file: File) {
        let previewController: PreviewViewController = previewSDK.openFile(file: file, delegate: self)
        navigationController?.pushViewController(previewController, animated: true)
    }
}

extension ViewController: PreviewViewControllerDelegate {

    func previewViewControllerFailed(error: BoxPreviewError) {
        print(error)
    }

    func makeCustomErrorView() -> ErrorView? {
        // Create custom error view here
        return nil
    }
}
