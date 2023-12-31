//
//  ImageStoreStoreSpy.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 01/12/2023.
//

import Foundation
@testable import PhotoSearchApp

final class ImageStoreStoreSpy: ImageDataStore {
    enum Message: Equatable {
        case insert(Data, for: String)
    }
    
    private(set) var messages = [Message]()
    private var completions = [(Result<Void, Error>) -> Void]()
    
    func insert(data: Data, for key: String, completion: @escaping (Result<Void, Error>) -> Void) {
        messages.append(.insert(data, for: key))
        completions.append(completion)
    }
    
    func completeWithError(at index: Int = 0) {
        completions[index](.failure(anyNSError()))
    }
    
    func completeSuccessfully(at index: Int = 0) {
        completions[index](.success(()))
    }
}
