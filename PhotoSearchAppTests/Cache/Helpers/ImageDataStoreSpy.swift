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
    private var insertionCompletions = [(InsertResult) -> Void]()
    private var retrievalCompletions = [(RetrieveResult) -> Void]()
    
    func insert(_ data: Data, for key: String, completion: @escaping (InsertResult) -> Void) {
        messages.append(.insert(data, for: key))
        insertionCompletions.append(completion)
    }
    
    func completeInsertionWithError(at index: Int = 0) {
        insertionCompletions[index](.failure(anyNSError()))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
    func retrieveData(for key: String, completion: @escaping (RetrieveResult) -> Void) {
        messages.append(.retrieveData(for: key))
        retrievalCompletions.append(completion)
    }
    
    func completeRetrievalWithError(at index: Int = 0) {
        retrievalCompletions[index](.failure(anyNSError()))
    }
    
    func completeRetrievalWithNoData(at index: Int = 0) {
        retrievalCompletions[index](.success(nil))
    }
    
    func completeRetrieval(with data: Data, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
}
