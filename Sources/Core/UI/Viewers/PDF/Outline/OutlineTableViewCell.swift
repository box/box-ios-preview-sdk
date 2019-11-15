//
//  OutlineTableViewCell.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 7/10/19.
//  Copyright © 2019 Box. All rights reserved.
//

import PDFKit
import UIKit

class OutlineTableViewCell: UITableViewCell {

    // MARK: - Properties

    private lazy var pageNumberlabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        return label
    }()

    private lazy var childIndicator: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(childIndicatorPressed), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabelLeftContraints: NSLayoutConstraint = {
        childIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10)
    }()

    var childIndicatorAction: ((_ sender: UIButton) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        pageNumberlabel.text = ""
        childIndicator.alpha = 0.0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if indentationLevel == 0 {
            titleLabel.font = UIFont.systemFont(ofSize: 14)
        }
        else {
            titleLabel.font = UIFont.systemFont(ofSize: 12)
        }
        let identation = CGFloat(indentationWidth * CGFloat(indentationLevel)) * -1
        titleLabelLeftContraints.constant = 10 + identation
    }

    // MARK: - Helpers

    func configure(with outline: PDFOutline) {
        titleLabel.text = outline.label
        pageNumberlabel.text = outline.destination?.page?.label

        let openImage = UIImage(named: "arrow_down", in: Bundle(for: type(of: self)), compatibleWith: nil)
        let closeImage = UIImage(named: "arrow_right", in: Bundle(for: type(of: self)), compatibleWith: nil)
        if outline.numberOfChildren > 0 {
            childIndicator.setImage(outline.isOpen ? openImage : closeImage, for: .normal)
            childIndicator.isEnabled = true
        }
        else {
            childIndicator.setImage(nil, for: .normal)
            childIndicator.isEnabled = false
        }

        titleLabel.text = outline.label
        pageNumberlabel.text = "\(outline.destination?.page?.label ?? "")"
        childIndicator.alpha = outline.numberOfChildren == 0 ? 0.0 : 1.0
    }

    @objc private func childIndicatorPressed(_ sender: UIButton) {
        sender.isSelected.toggle()
        childIndicatorAction?(sender)
    }
}

// MARK: - Private Helpers

private extension OutlineTableViewCell {
    private func setupViews() {
        backgroundColor = .white
        selectionStyle = .none
        contentView.addSubview(childIndicator)
        contentView.addSubview(titleLabel)
        contentView.addSubview(pageNumberlabel)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabelLeftContraints,
            childIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            childIndicator.widthAnchor.constraint(equalToConstant: 30),
            childIndicator.heightAnchor.constraint(equalToConstant: 30)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: childIndicator.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            pageNumberlabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            pageNumberlabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            pageNumberlabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
    }
}
