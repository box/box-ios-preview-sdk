//
//  OutlineViewController.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 7/10/19.
//  Copyright © 2019 Box. All rights reserved.
//

import PDFKit
import UIKit

protocol OutlineViewControllerDelegate: AnyObject {
    func outlineViewController(_ outlineViewController: OutlineViewController, didSelect page: PDFPage)
}

class OutlineViewController: UIViewController {

    // MARK: - Properties

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.rowHeight = 50
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.registerClass(OutlineTableViewCell.self)
        return tableView
    }()

    private var data = [PDFOutline]()
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var outline: PDFOutline!

    weak var delegate: OutlineViewControllerDelegate?

    // MARK: - Life cycle

    init(outline: PDFOutline, delegate: OutlineViewControllerDelegate?) {
        self.outline = outline
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension OutlineViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(OutlineTableViewCell.self, indexPath: indexPath)
        let outline = data[indexPath.row]
        cell.configure(with: outline)
        cell.childIndicatorAction = { [weak self] sender in
            if outline.numberOfChildren > 0 {
                if sender.isSelected {
                    outline.isOpen = true
                    self?.insertChirchen(parent: outline)
                }
                else {
                    outline.isOpen = false
                    self?.removeChildren(parent: outline)
                }
                tableView.reloadData()
            }
        }
        return cell
    }

    func tableView(_: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        let outline = data[indexPath.row]
        let depth = findDepth(outline: outline)
        return depth
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let page = data[indexPath.row].destination?.page {
            delegate?.outlineViewController(self, didSelect: page)
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Private helpers

private extension OutlineViewController {
    func setupView() {
        view.backgroundColor = .white
        title = "Outline"
        setupTableView()
        setupNavigationItems()
        setupOutlineData()
    }

    func setupOutlineData() {
        for index in 0 ... outline.numberOfChildren - 1 {
            if let pdfOutline = outline.child(at: index) {
                pdfOutline.isOpen = false
                data.append(pdfOutline)
            }
        }
        tableView.reloadData()
    }

    func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func setupNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "dismiss", in: Bundle(for: type(of: self)), compatibleWith: nil),
            style: .plain, target: self, action: #selector(close)
        )
    }

    @objc private func close() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    func findDepth(outline: PDFOutline) -> Int {
        var depth: Int = -1
        var tmp = outline
        while tmp.parent != nil {
            depth += depth + 1
            // swiftlint:disable:next force_unwrapping
            tmp = tmp.parent!
        }
        return depth
    }

    func insertChirchen(parent: PDFOutline) {
        var tmpData: [PDFOutline] = []
        guard let baseIndex = self.data.firstIndex(of: parent) else {
            return
        }

        for index in 0 ..< parent.numberOfChildren {
            if let pdfOutline = parent.child(at: index) {
                pdfOutline.isOpen = false
                tmpData.append(pdfOutline)
            }
        }
        data.insert(contentsOf: tmpData, at: baseIndex + 1)
    }

    func removeChildren(parent: PDFOutline) {
        if parent.numberOfChildren <= 0 {
            return
        }

        for index in 0 ..< parent.numberOfChildren {
            guard let node = parent.child(at: index) else {
                return
            }

            if node.numberOfChildren > 0 {
                removeChildren(parent: node)

                // remove self
                if let removeIndex = data.firstIndex(of: node) {
                    data.remove(at: removeIndex)
                }
            }
            else {
                if data.contains(node) {
                    if let removeIndex = data.firstIndex(of: node) {
                        data.remove(at: removeIndex)
                    }
                }
            }
        }
    }
}
