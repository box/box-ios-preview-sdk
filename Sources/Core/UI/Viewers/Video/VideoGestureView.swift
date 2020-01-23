//
//  VideoGestureView.swift
//  BoxPreviewSDK-iOS
//
//  Created by Sujay Garlanka on 1/22/20.
//  Copyright © 2020 Box. All rights reserved.
//

import UIKit

final class AVGestureView: UIView {
    
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
//        setupView()
    }

    // MARK: - Private helpers

    private func setupView() {
//        translatesAutoresizingMaskIntoConstraints = false
//        backgroundColor = .clear
    }
}
