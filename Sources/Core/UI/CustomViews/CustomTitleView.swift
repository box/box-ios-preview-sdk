//
//  CustomTitleView.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 7/1/19.
//  Copyright © 2019 Box. All rights reserved.
//

import Foundation
import UIKit

final class CustomTitleView: UIStackView {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()

    lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])

        return stackView
    }()

    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    public var subtitle: String? {
        didSet {
            subtitleLabel.text = subtitle
        }
    }

    // MARK: Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .vertical
        addArrangedSubview(titleLabel)
        addArrangedSubview(subtitleLabel)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
