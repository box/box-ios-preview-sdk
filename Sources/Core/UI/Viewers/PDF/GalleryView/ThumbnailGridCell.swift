//
//  ThumbnailGridCell.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 7/1/19.
//  Copyright © 2019 Box. All rights reserved.
//

import PDFKit
import UIKit

class ThumbnailGridCell: UICollectionViewCell {
    // MARK: - UI Related

    private lazy var pageImageView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        return img
    }()

    private lazy var pageNumberButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        button.titleLabel?.textAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.layer.cornerRadius = 3
        button.clipsToBounds = false
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    // MARK: - Life cycle

    required override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        pageImageView.image = nil
        pageNumberButton.setTitle("", for: .normal)
    }

    // MARK: - Private Helpers

    private func setupViews() {
        backgroundColor = .white
        contentView.addSubview(pageImageView)
        contentView.addSubview(pageNumberButton)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pageImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pageImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pageImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            pageImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            pageNumberButton.centerXAnchor.constraint(equalTo: pageImageView.centerXAnchor),
            pageNumberButton.bottomAnchor.constraint(equalTo: pageImageView.bottomAnchor, constant: -10)
        ])
    }

    // MARK: - Helpers

    func configure(with image: UIImage?, page: String?) {
        pageImageView.image = image ?? UIImage(named: "error", in: Bundle(for: type(of: self)), compatibleWith: nil)
        pageNumberButton.setTitle(page, for: .normal)
    }
}
