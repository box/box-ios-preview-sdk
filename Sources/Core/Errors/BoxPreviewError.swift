//
//  BoxPreviewError.swift
//  BoxPreviewSDK-iOS
//
//  Created by Patrick Simon on 7/17/19.
//  Copyright © 2019 Box. All rights reserved.
//

import BoxSDK
import Foundation

public enum BoxPreviewErrorEnum: BoxEnum {
    
    case fileCouldNotBeDownloaded
    case fileCouldNotBeDecoded
    case unableToReadFile(String)
    case unknownFileType(String)
    case unableToAccessFilesDirectory
    case unableToFindImage
    
    // SearchHistory
    case invalidURLForSearchHistoryStore
    case invalidSearchHistoryData
    
    case contentSDKError
    
    case customValue(String)

    public init(_ value: String) {
        switch value {
        case "fileCouldNotBeDownloaded":
            self = .fileCouldNotBeDownloaded
        case "fileCouldNotBeDecoded":
            self = .fileCouldNotBeDecoded
        case "unableToAccessFilesDirectory":
            self = .unableToAccessFilesDirectory
        case "unableToFindImage":
            self = .unableToFindImage
        case "invalidURLForSearchHistoryStore":
            self = .invalidURLForSearchHistoryStore
        case "invalidSearchHistoryData":
            self = .invalidSearchHistoryData
        default:
            self = .customValue(value)
        }
    }

    public var description: String {
        switch self {
        case .fileCouldNotBeDownloaded:
            return "File could not be downloaded"
        case .fileCouldNotBeDecoded:
            return "File could not be decoded"
        case let .unableToReadFile(fileName):
            return "Unable to read file: \(fileName)"
        case let .unknownFileType(fileType):
            return "Unknown file type: \(fileType)"
        case .unableToAccessFilesDirectory:
            return "Unable to access files directory"
        case .unableToFindImage:
            return "Unable to find image"
        case .invalidURLForSearchHistoryStore:
            return "Invalid URL for search history store"
        case .invalidSearchHistoryData:
            return "Invalid search history data"
        case .contentSDKError:
            return "Content SDK Error"
        case let .customValue(userValue):
            return userValue
        }
    }
}

extension BoxPreviewErrorEnum: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = BoxPreviewErrorEnum(value)
    }
}

/// Describes Preview SDK errors
public class BoxPreviewError: Error {
    public var errorType: String
    public var message: BoxPreviewErrorEnum
    public var stackTrace: [String]
    public var error: Error?

    init(message: BoxPreviewErrorEnum = "General Preview Error", error: Error? = nil) {
        errorType = "BoxPreviewError"
        self.message = message
        stackTrace = Thread.callStackSymbols
        self.error = error
    }

    public func getDictionary() -> [String: Any] {
        var dict = [String: Any]()
        dict["errorType"] = errorType
        dict["message"] = message.description
        dict["stackTrace"] = stackTrace
        dict["error"] = error?.localizedDescription
        return dict
    }
}

extension BoxPreviewError: CustomStringConvertible {
    /// Provides error JSON string if found.
    public var description: String {
        guard
            let encodedData = try? JSONSerialization.data(withJSONObject: getDictionary(), options: [.prettyPrinted, .sortedKeys]),
            let JSONString = String(data: encodedData, encoding: .utf8) else {
            return "<Unparsed Box Preview Error>"
        }
        return JSONString.replacingOccurrences(of: "\\", with: "")
    }
}

extension BoxPreviewError: LocalizedError {
    public var errorDescription: String? {
        return message.description
    }
}
