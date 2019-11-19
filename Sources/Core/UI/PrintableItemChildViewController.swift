//
//  PrintableItemChildViewController.swift
//  BoxPreviewSDK-iOS
//
//  Created by Martina Stremeňová on 8/6/19.
//  Copyright © 2019 Box. All rights reserved.
//

import UIKit

protocol PrintableItemChildViewController: UIViewController {}
extension PrintableItemChildViewController {

    func print(fileAt url: URL) {
        if UIPrintInteractionController.canPrint(url) {
            print(item: url)
        }
    }

    func print(from data: Data) {
        if UIPrintInteractionController.canPrint(data) {
            print(item: data)
        }
    }

    func print(_ image: UIImage) {
        print(item: image)
    }

    private func print(item: Any) {
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = "Print file" // TODO: Localize
        printInfo.outputType = .general

        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.showsNumberOfCopies = true
        printController.printingItem = item

        printController.present(animated: true, completionHandler: nil)
    }
}
