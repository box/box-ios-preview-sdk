//
//  SearchQueryRepository.swift
//  BoxPreviewSDK-iOS
//
//  Created by Abel Osorio on 8/12/19.
//  Copyright © 2019 Box. All rights reserved.
//

import Foundation
import PDFKit

class SearchQueryRepository {
    // swiftlint:disable:next force_unwrapping
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("search-history.store")
    
    func saveSearchResults(searchResults: [String], completion: @escaping (Result<Void, BoxPreviewError>) -> Void) {
        do {
            let encoded = try JSONEncoder().encode(searchResults)
            try encoded.write(to: storeURL)
        } catch {
            completion(.failure(BoxPreviewError(message: .invalidSearchHistoryData)))
        }
    }

    func retreiveSearchHistory(completion: @escaping (Result<[String], BoxPreviewError>) -> Void) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.failure(BoxPreviewError(message: .invalidURLForSearchHistoryStore)))
            return
        }
        do {
            let cachedSearchHistory = try JSONDecoder().decode([String].self, from: data)
            completion(.success(cachedSearchHistory))
        } catch {
            completion(.failure(BoxPreviewError(message: .invalidSearchHistoryData)))
        }
    }

    func clearSearchResults(completion: @escaping (Error?) -> Void) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            return completion(nil)
        }
        
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
