//
//  PreviewHelper.swift
//  BoxPreviewSDK-iOS
//
//  Created by Patrick Simon on 7/15/19.
//  Copyright © 2019 Box. All rights reserved.
//

import BoxSDK
import Foundation
import PDFKit

internal class PreviewHelper {
    
    // MARK: - Properties
    
    var client: BoxClient
    var fileId: String
    var filePath: URL?
    private var supportedFileFormat = ["pdf", "jpg", "jpeg", "png", "tiff", "tif", "gif", "bmp", "BMPf", "ico", "cur", "xbm"]
    
    // MARK: - Init
    
    public init(client: BoxClient, fileId: String) {
        self.client = client
        self.fileId = fileId
    }
    
    // MARK: - Helpers
    
    func downloadBoxFile(progress: @escaping (Progress) -> Void, completion: @escaping (Result<Void, BoxSDKError>) -> Void) {
        client.files.get(fileId: fileId) { [weak self] (result: Result<File, BoxSDKError>) in
            guard let self = self else {
                return
            }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                return
                
            case let .success(file):
                self.downloadFile(file: file, progress: progress, completion: completion)
            }
        }
    }
    
    
    func getChildViewController(withActions actions: [FileInteractions]) -> Result<PreviewItemChildViewController, BoxPreviewError> {
        var childViewController: PreviewItemChildViewController
        
        guard let unwrappedFileURL = filePath else {
            return .failure(BoxPreviewError(message: .fileCouldNotBeDownloaded))
        }
        
        switch unwrappedFileURL.pathExtension {
        case "pdf":
            do {
                let data = try Data(contentsOf: unwrappedFileURL)
                if let document = PDFDocument(data: data) {
                    childViewController = PDFViewController(document: document, title: unwrappedFileURL.lastPathComponent, actions: actions)
                    return .success(childViewController)
                }
                else {
                    return .failure(BoxPreviewError(message: .unableToReadFile(fileId)))
                }
            }
            catch {
                return .failure(BoxPreviewError(error: error))
            }
        case "jpg", "jpeg", "png", "tiff", "tif", "gif", "bmp", "BMPf", "ico", "cur", "xbm":
            do {
                let data = try Data(contentsOf: unwrappedFileURL)
                if let image = UIImage(data: data) {
                    childViewController = ImageViewController(image: image, title: unwrappedFileURL.lastPathComponent, actions: actions)
                    return .success(childViewController)
                }
                else {
                    return .failure(BoxPreviewError(message: .unableToReadFile(fileId)))
                }
            }
            catch {
                return .failure(BoxPreviewError(error: error))
            }
        default:
            return .failure(BoxPreviewError(message: .unknownFileType(unwrappedFileURL.pathExtension)))
        }
    }
    
    
    // MARK: - Private helpers
    
    private func downloadFile(file: File, progress: @escaping (Progress) -> Void,
                              completion: @escaping (Result<Void, BoxSDKError>) -> Void) {
        guard let fileName = file.name,
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
        }
        var fileURL = documentsURL.appendingPathComponent(fileName)
        if supportedFileFormat.contains(fileURL.pathExtension) {
            self.client.files.download(
                fileId: file.id,
                destinationURL: fileURL,
                progress: progress,
                completion: { [weak self] (result: Result<Void, BoxSDKError>) in
                    guard let self = self else {
                        return
                    }
                    
                    completion(self.processFileDownload(to: fileURL, result: result))
                }
            )
        } else {
            fileURL = fileURL.deletingPathExtension().appendingPathExtension("pdf")
            self.client.files.getRepresentationContent(
                fileId: file.id,
                representationHint: .pdf,
                destinationURL: fileURL,
                progress: progress,
                completion: { [weak self] (result: Result<Void, BoxSDKError>) in
                    guard let self = self else {
                        return
                    }
                    completion(self.processFileDownload(to: fileURL, result: result))
            })
        }
    }
    
    private func processFileDownload(to fileURL: URL, result: Result<Void, BoxSDKError>) -> Result<Void, BoxSDKError> {
        switch result {
        case .success:
            self.filePath = fileURL
            return .success(())
        case let .failure(error):
            return .failure(error)
        }
    }
}
