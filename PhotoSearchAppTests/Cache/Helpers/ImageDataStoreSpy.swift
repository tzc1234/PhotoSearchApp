//
//  ImageDataStoreSpy.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 01/12/2023.
//

import Foundation
@testable import PhotoSearchApp

final class ImageDataStoreSpy: ImageDataStore {
    enum Message: Equatable {
        case insert(Data, for: String)
        case retrieveData(for: String)
    }
    
    private(set) var messages = [Message]()
    private var completions = [(InsertResult) -> Void]()
    
    func insert(_ data: Data, for key: String, completion: @escaping (InsertResult) -> Void) {
        messages.append(.insert(data, for: key))
        completions.append(completion)
    }
    
    func completeInsertionWithError(at index: Int = 0) {
        completions[index](.failure(anyNSError()))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        completions[index](.success(()))
    }
    
    func retrieveData(for key: String) {
        messages.append(.retrieveData(for: key))
    }
}
