//
//  DefaultErrorView.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 7/18/19.
//  Copyright © 2019 Box. All rights reserved.
//

import BoxSDK
import UIKit

/// Custom error view for displaying errors from file preview.
public protocol ErrorView where Self: UIView {
    /// Handles displaying of error from file preview.Implement your own handling of BoxPreviewError.
    ///
    /// - Parameter error: Error occuring in file preview.
    func displayError(_ error: BoxPreviewError)
}

final class DefaultErrorView: UIView, ErrorView {
    
    // MARK: - Properties

    private lazy var errorTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.numberOfLines = 0
        label.text = "Oops"
        label.textColor = UIColor.lightGray
        return label
    }()

    private lazy var errorDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        return label
    }()

    private lazy var errorImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "error", in: Bundle(for: type(of: self)), compatibleWith: nil)
        return imageView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()

    // MARK: Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func displayError(_ error: BoxPreviewError) {
        var description: String = ""
        switch error.message {
        case .contentSDKError:
            if let SDKError = error.error as? BoxSDKError {
                description = SDKError.message.description
            }
            else {
                description = error.message.description
            }
        case let .customValue(message):
            if let generalError = error.error {
                description = generalError.localizedDescription
            }
            else {
                description = message
            }
        default:
            description = error.message.description
        }
        errorDescriptionLabel.text = description
    }
}

private extension DefaultErrorView {
    func setupView() {
        backgroundColor = .white
        setupSubviews()
    }

    func setupSubviews() {
        stackView.addArrangedSubview(errorImage)
        stackView.addArrangedSubview(errorTitleLabel)
        stackView.addArrangedSubview(errorDescriptionLabel)
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
}
