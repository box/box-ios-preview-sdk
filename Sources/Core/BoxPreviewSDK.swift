//
//  BoxPreviewSDK.swift
//  BoxPreviewSDK
//
//  Created by Box Inc on 01/04/19.
//  Copyright © 2019 Box Inc. All rights reserved.
//

import BoxSDK
import Foundation

public class BoxPreviewSDK {
    
    var client: BoxClient!
    // swiftlint:disable:previous implicitly_unwrapped_optional

    public init(client: BoxClient) {
        self.client = client
    }
}

// MARK: - Open Files

public extension BoxPreviewSDK {

    /// Opens image files with one image selected and preview of selectable thumbnails under it.
    ///
    /// - Parameters:
    ///   - fileIds: List of file ids to display. Other than image ids will be ignored.
    ///   - selectedId: ID of selected image to display first.
    ///   - delegate: Preview delegate to handle error in a custom way if needed.
    ///   - allowedAction: Actions user can do with a file, such as save to files or image library. All actions are allowed by default.
    /// - Returns: PreviewPageViewController to display.
    func openImageFiles(
        fileIds: [String],
        selectedId: String,
        delegate: PreviewViewControllerDelegate? = nil,
        allowedAction: [FileInteractions] = FileInteractions.allCases,
        displayThumbnails: Bool = false) -> PreviewPageViewController {
        guard let selectedFileIndex = fileIds.firstIndex(of: selectedId) else {
            fatalError("Provided wrong selected file id")
        }

        return PreviewPageViewController(
            client: client,
            fileIds: fileIds,
            index: selectedFileIndex,
            delegate: delegate,
            allowedActions: allowedAction,
            displayThumbnails: displayThumbnails
        )
    }

    /// Creates UIViewController for previewing file detail.
    ///
    /// - Parameters:
    ///   - fileId: Id of the file to preview.
    ///   - delegate: Delegate for catching the errors for further handling.
    ///   - allowedAction: Actions on image user can perform such as saving to library or files. By default all actions are allowed.
    ///   - customErrorView: Error view with custom design. To implement your own error view, implement ErrorView protocol and pass new error view here.
    ///     Error view is then displayed full screen.
    /// - Returns: Returns UIViewController displaying detail of the file.
    func openFile(fileId: String,
                  delegate: PreviewViewControllerDelegate? = nil,
                  allowedAction: [FileInteractions] = FileInteractions.allCases) -> PreviewViewController {
        return PreviewViewController(client: client, fileId: fileId, delegate: delegate, allowedActions: allowedAction)
    }
    
    /// Creates UIViewController for previewing file detail. This is the preferred openFile method as it makes less API calls than calling openFile with just the fileID.
    ///
    /// - Parameters:
    ///   - file: File Info object of the file to preview.
    ///   - delegate: Delegate for catching the errors for further handling.
    ///   - allowedAction: Actions on image user can perform such as saving to library or files. By default all actions are allowed.
    ///   - customErrorView: Error view with custom design. To implement your own error view, implement ErrorView protocol and pass new error view here.
    ///     Error view is then displayed full screen.
    /// - Returns: Returns UIViewController displaying detail of the file.
    func openFile(file: File,
                  delegate: PreviewViewControllerDelegate? = nil,
                  allowedAction: [FileInteractions] = FileInteractions.allCases) -> PreviewViewController {
        return PreviewViewController(client: client, file: file, delegate: delegate, allowedActions: allowedAction)
    }
}
