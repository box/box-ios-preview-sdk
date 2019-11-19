//
//  SearchHistoryTableViewCell.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 8/12/19.
//  Copyright © 2019 Box. All rights reserved.
//

import PDFKit
import UIKit

class SearchHistoryTableViewCell: UITableViewCell {
    // MARK: - Properties

    private lazy var searchLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    // MARK: Life cycle

    override func prepareForReuse() {
        super.prepareForReuse()
        searchLabel.text = ""
    }

    // MARK: - Helpers
    private func setupViews() {
        backgroundColor = .white
        selectionStyle = .none
        contentView.addSubview(searchLabel)

        NSLayoutConstraint.activate([
            searchLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            searchLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            searchLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            searchLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }

    func configure(with searchQuery: String) {
        searchLabel.text = searchQuery
    }
}
