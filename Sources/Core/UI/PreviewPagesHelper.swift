//
//  PreviewPagesHelper.swift
//  BoxPreviewSDK-iOS
//
//  Created by Martina Stremeňová on 8/13/19.
//  Copyright © 2019 Box. All rights reserved.
//

import BoxSDK
import Foundation
import PDFKit

class PreviewPagesHelper {

    var currentFileIdIndex: Int

    private(set) var client: BoxClient
    private(set) var fileIds: [String]
    private(set) var files: [File?] = []
    private(set) var viewControllers: [PreviewItemChildViewController?] = []

    private var filePaths: [String: URL] = [:]

    public init(client: BoxClient, fileIds: [String], selectedFileIndex: Int = 0) {
        self.client = client
        self.fileIds = fileIds
        currentFileIdIndex = selectedFileIndex
        files = Array(repeating: nil, count: fileIds.count)
    }

    func downloadFilesInfo(progress: @escaping (Progress) -> Void, completion: @escaping (Result<Void, BoxSDKError>) -> Void) {

        let dispatchGroup = DispatchGroup()
        var initialProgress: Int64 = 0

        progress(Progress(totalUnitCount: initialProgress))

        var lastDownloadError: BoxSDKError?
        for index in 0 ... (fileIds.count - 1) {
            let fileId = fileIds[index]
            dispatchGroup.enter()
            client.files.get(fileId: fileId) { [weak self] (result: Result<File, BoxSDKError>) in
                guard let self = self else {
                    return
                }
                switch result {
                case let .failure(error):
                    lastDownloadError = error

                case let .success(file):
                    self.files[index] = file

                    initialProgress += 1
                    progress(Progress(totalUnitCount: initialProgress))
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: DispatchQueue.main) {
            if let error = lastDownloadError {
                completion(.failure(error))
            }
            else {
                completion(.success(()))
            }
        }
    }
}

extension PreviewPagesHelper {
    // IMAGE ONLY PREVIEW - Filters out images
    func extractImageFiles() {

        let imageFiles: [File] = files.compactMap { [weak self] file in
            guard let self = self,
                let file = file else {
                return nil
            }
            return self.isImage(file: file) ? file : nil
        }
        currentFileIdIndex = imageFiles.firstIndex(where: { $0.id == fileIds[currentFileIdIndex] }) ?? 0
        files.removeAll()
        fileIds.removeAll()
        imageFiles.forEach { file in
            self.files.append(file)
            self.fileIds.append(file.id)
        }
    }

    /// IMAGE ONLY PREVIEW - Detects whether file is an image.
    ///
    /// - Parameter file: Standard file object containing file info.
    /// - Returns: Either false in case file is not an image or did not contain file name to decide OR true in case of an image.
    private func isImage(file: File) -> Bool {
        guard let fileName = file.name else {
            return false
        }
        return ["jpg", "jpeg", "png"].contains(where: fileName.contains)
    }
}
