//
//  CacheImageDataUseCaseTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 01/12/2023.
//

import XCTest

final class ImageDataCacher {
    private let store: CacheImageDataUseCaseTests.StoreSpy
    
    init(store: CacheImageDataUseCaseTests.StoreSpy) {
        self.store = store
    }
    
    func save(data: Data, for id: String) {
        store.insert(data: data, for: id)
    }
}

final class CacheImageDataUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_saveData_requestsStoreCachingWithDataAndId() {
        let (sut, store) = makeSUT()
        let data = Data("save data".utf8)
        let id = "image id"
        
        sut.save(data: data, for: id)
        
        XCTAssertEqual(store.messages, [.insert(data, for: id)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageDataCacher, store: StoreSpy) {
        let store = StoreSpy()
        let sut = ImageDataCacher(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
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
}
