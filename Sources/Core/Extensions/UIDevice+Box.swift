//
//  UIDevice+Box.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 7/17/19.
//  Copyright © 2019 Box. All rights reserved.
//

import UIKit

extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
