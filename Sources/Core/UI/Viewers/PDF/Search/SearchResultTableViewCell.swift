//
//  SearchResultTableViewCell.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 8/5/19.
//  Copyright © 2019 Box. All rights reserved.
//

import PDFKit
import UIKit

class SearchResultTableViewCell: UITableViewCell {

    private lazy var destinationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .blue
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()

    private lazy var resultTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var thumbnailImageViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0)
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        return stackView
    }()

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
        destinationLabel.text = ""
        resultTextLabel.text = ""
        thumbnailImageView.image = nil
    }

    private func setupViews() {
        backgroundColor = .white
        selectionStyle = .none
        stackView.addArrangedSubview(destinationLabel)
        stackView.addArrangedSubview(resultTextLabel)
        contentView.addSubview(thumbnailImageViewContainer)
        thumbnailImageViewContainer.addSubview(thumbnailImageView)
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            thumbnailImageViewContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageViewContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageViewContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            thumbnailImageViewContainer.widthAnchor.constraint(equalToConstant: 60)
        ])

        NSLayoutConstraint.activate([
            thumbnailImageView.centerYAnchor.constraint(equalTo: thumbnailImageViewContainer.centerYAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            thumbnailImageView.trailingAnchor.constraint(equalTo: thumbnailImageViewContainer.trailingAnchor, constant: -4),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 72)
        ])

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }

    func configure(with selection: PDFSelection, at index: Int, fromDocument document: PDFDocument) {
        let page = selection.pages[0]
        thumbnailImageView.image = page.thumbnail(of: CGSize(width: 240, height: 240), for: .trimBox)

        let outline = document.outlineItem(for: selection)
        let outlintstr = outline?.label ?? ""
        let pagestr = page.label ?? ""
        let txt = outlintstr + " page:  " + pagestr
        destinationLabel.text = txt

        // swiftlint:disable:next force_cast
        let extendSelection = selection.copy() as! PDFSelection
        extendSelection.extend(atStart: 10)
        extendSelection.extend(atEnd: 90)
        extendSelection.extendForLineBoundaries()

        // swiftlint:disable:next force_unwrapping
        let ranges = extendSelection.string!.ranges(of: selection.string!, options: .caseInsensitive)
        // swiftlint:disable:next force_unwrapping
        let attrstr = NSMutableAttributedString(string: extendSelection.string!)
        
        if ranges[safe:index] != nil {
            // swiftlint:disable:next force_unwrapping
            let nsRange = extendSelection.string!.nsRange(from: ranges[index])
            attrstr.addAttribute(.backgroundColor, value: UIColor.yellow, range: nsRange)
        } else if ranges[safe:index-1] != nil {
            // swiftlint:disable:next force_unwrapping
            let nsRange = extendSelection.string!.nsRange(from: ranges[index-1])
            attrstr.addAttribute(.backgroundColor, value: UIColor.yellow, range: nsRange)
        }
        else {
            // swiftlint:disable:next force_unwrapping
            let nsRange = extendSelection.string!.nsRange(from: ranges[0])
            attrstr.addAttribute(.backgroundColor, value: UIColor.yellow, range: nsRange)
        }
        resultTextLabel.attributedText = attrstr
    }
}
