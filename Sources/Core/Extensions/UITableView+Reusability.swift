//
//  UITableView+Reusability.swift
//  Brix
//
//  Created by Abel Osorio on 7/1/19.
//  Copyright © 2019 Box. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    func registerClass(_ cellClasses: AnyClass...) {
        for aClass in cellClasses {
            register(aClass, forCellReuseIdentifier: String(describing: aClass))
        }
    }

    func registerNib(_ cellClasses: AnyClass...) {
        for aClass in cellClasses {
            let string = String(describing: aClass)
            register(UINib(nibName: string, bundle: nil), forCellReuseIdentifier: string)
        }
    }

    func registerHeaderFooterNib(_ cellClasses: AnyClass...) {
        for aClass in cellClasses {
            let string = String(describing: aClass)
            register(UINib(nibName: string, bundle: nil), forHeaderFooterViewReuseIdentifier: string)
        }
    }

    func dequeue<T: UITableViewCell>(_ cellClass: T.Type, indexPath: IndexPath? = nil) -> T {
        let string = String(describing: cellClass)

        if let indexPath = indexPath {
            // swiftlint:disable:next force_cast
            return dequeueReusableCell(withIdentifier: string, for: indexPath) as! T
        }
        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withIdentifier: string) as! T
    }

    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ cellClass: T.Type) -> T {
        let string = String(describing: cellClass)
        // swiftlint:disable:next force_cast
        return dequeueReusableHeaderFooterView(withIdentifier: string) as! T
    }
}
