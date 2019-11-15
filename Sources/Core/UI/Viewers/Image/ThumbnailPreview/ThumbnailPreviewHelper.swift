//
//  ThumbnailPreviewHelper.swift
//  BoxPreviewSDK-iOS
//
//  Created by Martina Stremeňová on 8/8/19.
//  Copyright © 2019 Box. All rights reserved.
//

import BoxSDK
import UIKit

typealias ImageAtIndex = (image: UIImage?, index: Int)

class ThumbnailPreviewHelper {

    var itemCount: Int {
        return fileIds.count
    }

    private(set) var selectedIndex: Int

    private let fileIds: [String]
    private var thumbnails: [UIImage?]
    private let client: BoxClient

    init(
        client: BoxClient,
        fileIds: [String],
        imageIndex: Int
    ) {
        self.fileIds = fileIds
        self.client = client
        selectedIndex = imageIndex

        thumbnails = Array(repeating: nil, count: fileIds.count)
    }

    func getThumbnailImage(
        ofMaxHeight maxHeight: Int,
        maxWidth: Int,
        atIndex index: Int,
        completion: @escaping (Result<ImageAtIndex, Error>) -> Void
    ) {
        if let image = thumbnails[index] {
            completion(.success((image, index)))
            return
        }
        client.files.getThumbnail(
            forFile: fileIds[index],
            extension: .png,
            maxHeight: maxHeight,
            maxWidth: maxWidth
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case let .success(imageData):
                guard let image = UIImage(data: imageData) else {
                    DispatchQueue.main.async {
                        completion(.failure(BoxPreviewError(message: .fileCouldNotBeDecoded)))
                    }
                    return
                }
                self.thumbnails[index] = image
                DispatchQueue.main.async {
                    completion(.success((image, index)))
                }
            case let .failure(downloadError):
                DispatchQueue.main.async {
                    completion(.failure(downloadError))
                }
            }
        }
    }
}
