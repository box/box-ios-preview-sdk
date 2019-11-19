//
//  SearchViewController.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 8/5/19.
//  Copyright © 2019 Box. All rights reserved.
//

import PDFKit
import UIKit

protocol SearchViewControllerDelegate: AnyObject {
    func userDidTapOnSearchResult(selection: PDFSelection, searchResults: [PDFSelection])
}

class SearchViewController: UIViewController {
    // MARK: - Properties

    enum Mode {
        case searching
        case searchHistory
    }
    
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var document: PDFDocument!
    private var searchResults: [PDFSelection] = []
    private var searchedItemsDictionary: [String: [PDFSelection]] = [:]
    private var searchHistory: [String] = []
    private var mode: Mode = .searchHistory {
        didSet {
            tableView.reloadData()
        }
    }
    private var searchHistoryHelper = SearchQueryRepository()
    private var viewTitle: String?
    private lazy var titleView: CustomTitleView = {
        let view: CustomTitleView = CustomTitleView()
        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 150
        tableView.tableFooterView = UIView()
        tableView.registerClass(SearchResultTableViewCell.self)
        tableView.registerClass(SearchHistoryTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        return tableView
    }()
    
    private lazy var resultsCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.alpha = 0.0
        return label
    }()
    
    private lazy var emptyResultsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = "No matches found"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.alpha = 0.0
        return label
    }()
    private lazy var searchViewController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search Document"
        search.searchBar.delegate = self
        return search
    }()
    
    weak var delegate: SearchViewControllerDelegate?
    
    public init(document: PDFDocument, title: String? = nil, delegate: SearchViewControllerDelegate) {
        self.document = document
        self.delegate = delegate
        viewTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async { [weak self] in
            self?.searchViewController.searchBar.becomeFirstResponder()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveSearchHistory()
    }
    
    // MARK: - Actions

    @objc private func closeTapped() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Private helpers

private extension SearchViewController {
    func setupView() {
        view.backgroundColor = .white
        setupTitleView()
        setupUISearchController()
        setupDocument()
        setupTableView()
        setupNavigationItems()
        setupSearchResultsView()
        setupEmptyResultsView()
        retriveSearchHistory()
    }
    
    func setupTitleView() {
        titleView.title = viewTitle
        navigationItem.titleView = titleView
    }
    func setupNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "dismiss", in: Bundle(for: type(of: self)), compatibleWith: nil),
            style: .plain, target: self, action: #selector(closeTapped)
        )
    }
    func setupUISearchController() {
        navigationItem.searchController = searchViewController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    func setupDocument() {
        document.delegate = self
    }

    func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)

            ])
    }
    
    func setupSearchResultsView() {
        view.addSubview(resultsCountLabel)
        NSLayoutConstraint.activate([
            resultsCountLabel.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            resultsCountLabel.heightAnchor.constraint(equalToConstant: 44),
            resultsCountLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            resultsCountLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
        searchViewController.isActive = true
    }
    
    func setupEmptyResultsView() {
        view.addSubview(emptyResultsLabel)
        NSLayoutConstraint.activate([
            emptyResultsLabel.bottomAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.topAnchor, constant: 44),
            emptyResultsLabel.heightAnchor.constraint(equalToConstant: 44),
            emptyResultsLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            emptyResultsLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
    }

    func updateResultCount() {
        guard let query = searchViewController.searchBar.text, !query.isEmpty else {
            emptyResultsLabel.alpha = 0.0
            return
        }
        
        if !searchResults.isEmpty {
            resultsCountLabel.text = "\(searchResults.count) matches found"
            resultsCountLabel.alpha = 1.0
            emptyResultsLabel.alpha = 0.0
        }
        else {
            resultsCountLabel.text = ""
            resultsCountLabel.alpha = 0.0
            emptyResultsLabel.alpha = 1.0
        }
    }
    
    func retriveSearchHistory() {
        searchHistoryHelper.retreiveSearchHistory { [weak self] result in
            switch result {
            case let .success(searchHistory):
                self?.searchHistory = searchHistory
            case let .failure(error):
                print(error)
            }
        }
    }
    
    func saveSearchHistory() {
        searchHistoryHelper.saveSearchResults(searchResults: searchHistory) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                print(error)
            }
        }
    }
    
    func clearSearchHistory() {
        searchHistoryHelper.clearSearchResults { [weak self] error in
            guard let self = self else {
                return
            }
            
            if error == nil {
                self.searchHistory.removeAll()
                self.tableView.reloadData()
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        switch mode {
        case .searching:
            return searchedItemsDictionary.keys.count
        case .searchHistory:
            return 1
        }
    }
    
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .searching:
            let keys = Array(searchedItemsDictionary.keys).sorted()
            guard let itemsPerKey = searchedItemsDictionary[keys[section]] else {
                return 0
            }
            return itemsPerKey.count
        case .searchHistory:
            return searchHistory.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch mode {
        case .searching:
            return 150
        case .searchHistory:
            return 44
        }
    }
    
    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch mode {
        case .searching:
            let cell = tableView.dequeue(SearchResultTableViewCell.self, indexPath: indexPath)
            let selection = pdfSelection(for: indexPath)
            cell.configure(with: selection, at: indexPath.row, fromDocument: document)
            return cell
        case .searchHistory:
            let cell = tableView.dequeue(SearchHistoryTableViewCell.self, indexPath: indexPath)
            cell.configure(with: searchHistory[indexPath.row])
            return cell
        }
    }
    
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch mode {
        case .searching:
            let selection = pdfSelection(for: indexPath)
            delegate?.userDidTapOnSearchResult(selection: selection, searchResults: searchResults)
            appendSearchQueryToSearchHistory()
            navigationController?.dismiss(animated: true, completion: nil)
        case .searchHistory:
            searchViewController.searchBar.text = searchHistory[indexPath.row]
            searchViewController.searchBar.becomeFirstResponder()
            performSearch(query: searchHistory[indexPath.row])
        }
    }
    
    private func pdfSelection(for indexPath: IndexPath) -> PDFSelection {
        let keys = Array(searchedItemsDictionary.keys).sorted()
        
        guard let pdfSelectionForPage = searchedItemsDictionary[keys[indexPath.section]] else {
            fatalError("We couldn't find the PDFSelection from that index.")
        }
        
        return pdfSelectionForPage[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch (mode, searchHistory.isEmpty) {
        case (.searching, _), (.searchHistory, true):
            return 0
        case (.searchHistory, false):
            let header = SearchHistoryHeaderView()
            header.delegate = self
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch (mode, searchHistory.isEmpty) {
        case (.searching, _), (.searchHistory, true):
            return nil
        case (.searchHistory, false):
            let header = SearchHistoryHeaderView()
            header.delegate = self
            return header
        }
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty, !query.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            return
        }
        performSearch(query: query)
        appendSearchQueryToSearchHistory()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        clearResults()
        document.cancelFindString()
        mode = .searchHistory
        emptyResultsLabel.alpha = 0.0
        appendSearchQueryToSearchHistory()
    }

    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            clearResults()
            document.cancelFindString()
            return
        }
        
        guard searchText.count > 2, !searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            clearResults()
            document.cancelFindString()
            emptyResultsLabel.alpha = 0.0
            mode = .searchHistory
            return
        }
        performSearch(query: searchText)
    }
    
    private func clearResults() {
        updateResultCount()
        searchResults.removeAll()
        searchedItemsDictionary.removeAll()
        tableView.reloadData()
        updateResultCount()
    }
    
    private func performSearch(query: String) {
        mode = .searching
        clearResults()
        document.cancelFindString()
        document.beginFindString(query, withOptions: [.caseInsensitive, .diacriticInsensitive])
    }
    
    private func appendSearchQueryToSearchHistory() {
        guard let query = searchViewController.searchBar.text?.trailingSpacesTrimmed, !query.isEmpty,
            !searchHistory.contains(where: { $0.caseInsensitiveCompare(query) == .orderedSame })  else {
            return
        }
        searchHistory.append(query)
    }
}

// MARK: - PDFDocumentDelegate

extension SearchViewController: PDFDocumentDelegate {
    func documentDidEndDocumentFind(_: Notification) {
        searchedItemsDictionary = Dictionary(grouping: searchResults,
                                             by: { item in item.pages[0].label ?? "" })
        updateResultCount()
        tableView.reloadData()
    }
    
    func documentDidFindMatch(_ notification: Notification) {
        if let selection = notification.userInfo?.first?.value as? PDFSelection {
            selection.color = .yellow
            searchResults.append(selection)
        }
    }
    
    func didMatchString(_ instance: PDFSelection) {
        searchResults.append(instance)
        updateResultCount()
        tableView.reloadData()
    }
}

// MARK: - SearchHistoryHeaderViewDelegate
extension SearchViewController: SearchHistoryHeaderViewDelegate {
    func userDidTapClear() {
        clearSearchHistory()
        tableView.reloadData()
        updateResultCount()
    }
}
