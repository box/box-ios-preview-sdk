//
//  UIViewController+Alert.swift
//  BoxPreviewSDK-iOS
//
//  Created by Martina Stremeňová on 8/6/19.
//  Copyright © 2019 Box. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlertWith(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(closeAction)
        present(alert, animated: true, completion: nil)
    }
}
