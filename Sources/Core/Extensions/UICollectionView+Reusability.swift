//
//  UICollectionView+Reusability.swift
//  Brix
//
//  Created by Abel Osorio on 7/1/19.
//  Copyright © 2019 Box. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    func registerClass(_ cellClasses: AnyClass...) {
        for aClass in cellClasses {
            register(aClass, forCellWithReuseIdentifier: String(describing: aClass))
        }
    }

    func registerNib(_ cellClasses: AnyClass...) {
        for aClass in cellClasses {
            let string = String(describing: aClass); register(
                UINib(nibName: string, bundle: nil),
                forCellWithReuseIdentifier: string
            )
        }
    }

    func dequeue<T: UICollectionViewCell>(_ cellClass: T.Type, indexPath: IndexPath) -> T {
        let string = String(describing: cellClass)

        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withReuseIdentifier: string, for: indexPath) as! T
    }
}
