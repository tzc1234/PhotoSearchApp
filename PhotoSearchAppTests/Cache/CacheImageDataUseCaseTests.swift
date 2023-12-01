//
//  CacheImageDataUseCaseTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 01/12/2023.
//

import XCTest

final class ImageDataCacher {
    private let store: StoreSpy
    
    init(store: StoreSpy) {
        self.store = store
    }
    
    func save(data: Data, for id: String) {
        store.insert(data: data, for: id)
    }
}

final class StoreSpy {
    enum Message: Equatable {
        case insert(Data, for: String)
    }
    
    private(set) var messages = [Message]()
    
    func insert(data: Data, for key: String) {
        messages.append(.insert(data, for: key))
    }
}

final class CacheImageDataUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let store = StoreSpy()
        _ = ImageDataCacher(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_saveData_requestsStoreCachingWithDataAndId() {
        let store = StoreSpy()
        let sut = ImageDataCacher(store: store)
        let data = Data("save data".utf8)
        let id = "image id"
        
        sut.save(data: data, for: id)
        
        XCTAssertEqual(store.messages, [.insert(data, for: id)])
    }
}
