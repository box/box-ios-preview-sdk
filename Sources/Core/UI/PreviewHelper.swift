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
import os.log

internal class PreviewHelper {
    
    // MARK: - Properties
    
    var client: BoxClient
    var file: File?
    var fileName: String?
    var filePath: URL?
    var AVFileFormat = ["mp4", "mov", "wmv", "flv", "avi", "mp3"]
    var otherFileFormat = ["pdf", "jpg", "jpeg", "png", "tiff", "tif", "gif", "bmp", "BMPf", "ico", "cur", "xbm"]
    var supportedFileFormat: [String] {
        return AVFileFormat + otherFileFormat
    }
    
    // MARK: - Init
    
    public init(client: BoxClient) {
        self.client = client
    }
    
    // MARK: - Helpers
    
    
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
                    childViewController = PDFViewController(document: document, title: fileName, actions: actions)
                    return .success(childViewController)
                }
                else {
                    return .failure(BoxPreviewError(message: .unableToReadFile(file?.id ?? "")))
                }
            }
            catch {
                return .failure(BoxPreviewError(error: error))
            }
        case "jpg", "jpeg", "png", "tiff", "tif", "gif", "bmp", "BMPf", "ico", "cur", "xbm":
            do {
                let data = try Data(contentsOf: unwrappedFileURL)
                if let image = UIImage(data: data) {
                    childViewController = ImageViewController(image: image, title: fileName, actions: actions)
                    return .success(childViewController)
                }
                else {
                    return .failure(BoxPreviewError(message: .unableToReadFile(file?.id ?? "")))
                }
            }
            catch {
                return .failure(BoxPreviewError(error: error))
            }
        case "mp4", "mov", "wmv", "flv", "avi", "mp3":
            childViewController = AVViewController(url: unwrappedFileURL, title: fileName, actions: actions)
            return .success(childViewController)

        case "m3u8":
            childViewController = AVViewController(url: unwrappedFileURL, title: fileName, client: client, actions: actions)
            return .success(childViewController)
//                do {
//                    var token: String;
//                    let semaphore = DispatchSemaphore(value: 1)
//                    self.client.session.getAccessToken() { result in
//                        defer { semaphore.signal() }
//                        switch result {
//                            case let .success(accessToken):
//                                token = accessToken
//                                childViewController = VideoViewController(url: unwrappedFileURL, title: unwrappedFileURL.lastPathComponent, token: token)
//                            case let .failure(error):
////                                return .failure(BoxPreviewError(error: error))
//                                print("hls failed")
//                        }
//                    }
//                    semaphore.wait()
//                }
//                catch {
//                    return .failure(BoxPreviewError(error: error))
//                }
        default:
            return .failure(BoxPreviewError(message: .unknownFileType(unwrappedFileURL.pathExtension)))
        }
    }
    
    func downloadFile(file: File,
                      representations: [FileRepresentation]? = nil,
                      progress: @escaping (Progress) -> Void,
                      completion: @escaping (Result<Void, BoxSDKError>) -> Void) {
        guard let fileName = file.name,
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
        }
        self.fileName = fileName
        self.file = file
        
        var fileURL = documentsURL.appendingPathComponent(fileName)
//        let streamAvailable = representations?.contains { $0.representation == "hls" } ?? false
        if let streamRepresentation = representations?.first(where: { $0.representation == "hls" }) {
            guard let streamURL = streamRepresentation.content?.urlTemplate else {
                return
            }
            fileURL = URL(fileURLWithPath: streamURL)
            fileURL.deleteLastPathComponent()
            fileURL.appendPathComponent("master.m3u8")
            completion(self.processFileDownload(to: fileURL, result: .success(())))
            print(fileURL.absoluteString)
        }
        else if supportedFileFormat.contains(fileURL.pathExtension) {
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
    
    // MARK: - Private helpers
    
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
