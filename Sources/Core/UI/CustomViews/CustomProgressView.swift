//
//  CustomProgressView.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 7/18/19.
//  Copyright © 2019 Box. All rights reserved.
//

import UIKit

final class CustomProgressView: UIView {
    
    // MARK: - Properties

    private lazy var percentageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Generating Preview"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        return label
    }()

    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
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

    // MARK: - Public helpers

    public func setProgress(_ progress: Double) {
        DispatchQueue.main.async {
            self.percentageLabel.text = "\(Int(progress * 100))%"
            self.progressView.progress = Float(progress)
        }
    }

    // MARK: - Private helpers

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        setupSubviews()
    }

    private func setupSubviews() {
        addSubview(percentageLabel)
        addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            progressView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            percentageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            percentageLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8)
        ])
    }
}
