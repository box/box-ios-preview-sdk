//
//  SearchHistoryHeaderView.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 8/15/19.
//  Copyright © 2019 Box. All rights reserved.
//

import UIKit

protocol SearchHistoryHeaderViewDelegate: AnyObject {
    func userDidTapClear()
}

class SearchHistoryHeaderView: UIView {
    // MARK: - Properties
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.text = "Recent"
        return label
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Clear", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: SearchHistoryHeaderViewDelegate?
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    // MARK: - Helpers
    
    private func setupViews() {
        backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        addSubview(titleLabel)
        addSubview(clearButton)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            clearButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            clearButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: -70),
            clearButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            clearButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    @objc func clearTapped() {
        delegate?.userDidTapClear()
    }
}
