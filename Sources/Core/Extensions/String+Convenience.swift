//
//  String+Convenience.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 8/22/19.
//  Copyright © 2019 Box. All rights reserved.
//

import Foundation

extension String {
    var trailingSpacesTrimmed: String {
        var newString = self
        
        while newString.last?.isWhitespace == true {
            newString = String(newString.dropLast())
        }
        
        return newString
    }
}
