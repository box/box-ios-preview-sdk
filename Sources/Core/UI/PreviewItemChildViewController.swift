//
//  PreviewItemChildViewController.swift
//  BoxPreviewSDK-iOS
//
//  Created by Martina Stremeňová on 8/6/19.
//  Copyright © 2019 Box. All rights reserved.
//

import UIKit

protocol PreviewItemFullScreenDelegate: AnyObject {
    func viewController(_ viewController: UIViewController, didEnterFullScreen: Bool)
}

protocol PreviewItemChildViewController: UIViewController {
    var fullScreenDelegate: PreviewItemFullScreenDelegate? { get set }
    var toolbarButtons: [UIBarButtonItem] { get }
}

extension PreviewItemChildViewController {

    // MARK: - Common toolbar buttons

    func makeSaveToFilesButton() -> UIBarButtonItem {
        return UIBarButtonItem(
            image: UIImage(named: "temp_save_files", in: Bundle(for: type(of: self)), compatibleWith: nil),
            style: .plain,
            target: self,
            action: nil
        )
    }

    func makePrintButton() -> UIBarButtonItem {
        return UIBarButtonItem(
            image: UIImage(named: "temp_toolbar_print", in: Bundle(for: type(of: self)), compatibleWith: nil),
            style: .plain,
            target: self,
            action: nil
        )
    }

    func makeShareButton() -> UIBarButtonItem {
        return UIBarButtonItem(
            image: UIImage(named: "temp_toolbar_share", in: Bundle(for: type(of: self)), compatibleWith: nil),
            style: .plain,
            target: self,
            action: nil
        )
    }

    func makeFlexiSpace() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
}

// MARK: - Print functionality

extension PreviewItemChildViewController {
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
        printInfo.jobName = "Print file"
        printInfo.outputType = .general

        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.showsNumberOfCopies = true
        printController.printingItem = item

        printController.present(animated: true, completionHandler: nil)
    }
}

extension PreviewItemChildViewController {
    // saves data to root folder
    func saveDataToFiles(_ data: Data, withName fileName: String) throws {
        let filesDirectory = FileManager.default.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        guard let path = filesDirectory.first else {
            throw BoxPreviewError(message: .unableToAccessFilesDirectory)
        }
        try data.write(to: path.appendingPathComponent(fileName))
    }

    /// Displays available share and other options for a file. Supports either data or Images.
    ///
    /// - Parameters:
    ///   - item: Data or UIImage.
    ///   - fileName: Name of the file.
    func displayAllShareOptions(for item: Any, withName fileName: String) {

        var itemData: Data?

        if let data = item as? Data {
            itemData = data
        }

        if let image = item as? UIImage {
            itemData = image.pngData()
        }

        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let path = documents?.appendingPathComponent(fileName) else {
            return
        }
        try? itemData?.write(to: path)

        let activityController: UIActivityViewController = UIActivityViewController(activityItems: [path], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceRect = self.view.bounds
        activityController.popoverPresentationController?.sourceView = self.view
        activityController.popoverPresentationController?.permittedArrowDirections = []
        present(activityController, animated: true, completion: nil)
    }
    
    /// Displays available share and other options for a file.
    ///
    /// - Parameters:
    ///   - filePath: URL of the file path to the downloaded file
    func displayAllShareOptions(filePath: URL) {
        let activityController: UIActivityViewController = UIActivityViewController(activityItems: [filePath], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceRect = self.view.bounds
        activityController.popoverPresentationController?.sourceView = self.view
        activityController.popoverPresentationController?.permittedArrowDirections = []
        present(activityController, animated: true, completion: nil)
    }
}
