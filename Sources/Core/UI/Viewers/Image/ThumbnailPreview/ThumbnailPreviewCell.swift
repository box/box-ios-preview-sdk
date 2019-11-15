//
//  ThumbnailPreviewCell.swift
//  BoxPreviewSDK-iOS
//
//  Created by Martina Stremeňová on 8/10/19.
//  Copyright © 2019 Box. All rights reserved.
//

import UIKit

class ThumbnailPreviewCell: UICollectionViewCell {

    // MARK: - Properties
    private(set) lazy var thumbnailImageView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        return img
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
        thumbnailImageView.image = nil
    }

    // MARK: - Private layout Helpers

    private func setupViews() {
        backgroundColor = .white
        contentView.addSubview(thumbnailImageView)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
