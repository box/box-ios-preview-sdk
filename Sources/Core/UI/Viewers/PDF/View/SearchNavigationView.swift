//
//  SearchNavigationView.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 8/19/19.
//  Copyright © 2019 Box. All rights reserved.
//

import UIKit
import PDFKit

protocol SearchNavigationViewDelegate: AnyObject {
    func nextPressed()
    func previousPressed()
}

final class SearchNavigationView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    private lazy var leftButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "arrow_left_blue", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        button.setImage(UIImage(named: "arrow_left_blue", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .highlighted)
        button.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
        return button
    }()
    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "arrow_right_blue", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        button.setImage(UIImage(named: "arrow_right_blue", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .highlighted)
        button.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        return button
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.spacing = 8
        stackView.addArrangedSubview(leftButton)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(rightButton)
        return stackView
    }()
    
    weak var delegate: SearchNavigationViewDelegate?

    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(currentIndex: Int, results: [PDFSelection]) {
        titleLabel.text = "Search Result \(currentIndex + 1) of \(results.count) results"
    }
    
    @objc private func nextTapped() {
        delegate?.nextPressed()
    }
    
    @objc private func previousTapped() {
        delegate?.previousPressed()
    }
}

// MARK: - SearchNavigationView
private extension SearchNavigationView {
    func setupView() {
        backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
