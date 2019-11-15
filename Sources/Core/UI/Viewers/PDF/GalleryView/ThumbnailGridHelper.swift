//
//  ThumbnailGridHelper.swift
//  BoxPreviewSDK-iOS
//
//  Created by Martina Stremeňová on 9/5/19.
//  Copyright © 2019 Box. All rights reserved.
//

import PDFKit
import BoxSDK
import Foundation

class ThumbnailGridHelper {

    private let document: PDFDocument?
    private let imageIds: [String]?
    private var thumbnails: [UIImage?]
    private let client: BoxClient?

    var itemCount: Int {
        return document?.pageCount ?? imageIds?.count ?? 0
    }

    init(document: PDFDocument) {
        self.document = document
        self.thumbnails = Array(repeating: nil, count: document.pageCount)
        self.imageIds = nil
        self.client = nil
    }

    init(imageIds: [String], client: BoxClient) {
        self.imageIds = imageIds
        self.client = client
        self.thumbnails = Array(repeating: nil, count: imageIds.count)
        self.document = nil
    }

    func getThumbnail(at index: Int, ofSize size: CGSize, completion: @escaping ((ImageAtIndex) -> Void)) {
        if let savedThumbnail = thumbnails[index] {
            completion(ImageAtIndex(savedThumbnail, index))
            return
        }

        if let document = document {
            let image = document.page(at: index)?.thumbnail(of: size, for: PDFDisplayBox.cropBox)
            thumbnails[index] = image
            completion(ImageAtIndex(image, index))
            return
        }

        downloadThumbnailImage(ofMaxHeight: Int(size.height), maxWidth: Int(size.width), atIndex: index) { [weak self] result in
            switch result {
            case let .success(imageAtIndex):
                completion(imageAtIndex)
                self?.thumbnails[imageAtIndex.index] = imageAtIndex.image
            case .failure:
                completion(ImageAtIndex(nil, index))
            }
        }
    }

    private func downloadThumbnailImage(
        ofMaxHeight maxHeight: Int,
        maxWidth: Int,
        atIndex index: Int,
        completion: @escaping (Result<ImageAtIndex, Error>) -> Void
        ) {
        guard let imageIds = self.imageIds else {
            return
        }

        client?.files.getThumbnail(
            forFile: imageIds[index],
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
