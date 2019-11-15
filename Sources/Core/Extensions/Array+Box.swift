//
//  Array+Box.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 8/14/19.
//  Copyright © 2019 Box. All rights reserved.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
