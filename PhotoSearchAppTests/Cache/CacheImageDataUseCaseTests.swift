//
//  CacheImageDataUseCaseTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 01/12/2023.
//

import XCTest

protocol ImageDataStore {
    func insert(data: Data, for key: String, completion: @escaping (Result<Void, Error>) -> Void)
}

final class ImageDataCacher {
    private let store: ImageDataStore
    
    init(store: ImageDataStore) {
        self.store = store
    }
    
    func save(data: Data, for id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        store.insert(data: data, for: id) { [weak self] result in
            guard self != nil else { return }
            
            completion(result)
        }
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
        
        sut.save(data: data, for: id) { _ in }
        
        XCTAssertEqual(store.messages, [.insert(data, for: id)])
    }
    
    func test_saveData_deliversErrorOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, completeWith: failureWithAnyError(), when: {
            store.completeWithError()
        })
    }
    
    func test_saveData_deliversNoErrorOnCachingSuccessfully() {
        let (sut, store) = makeSUT()
        
        expect(sut, completeWith: .success(()), when: {
            store.completeSuccessfully()
        })
    }
    
    func test_saveData_doesNotDeliverResultWhenSUTIsDeallocated() {
        let store = StoreSpy()
        var sut: ImageDataCacher? = ImageDataCacher(store: store)
        
        var loggedResults = [Result<Void, Error>]()
        sut?.save(data: anyData(), for: anyId()) { loggedResults.append($0) }
        
        sut = nil
        store.completeSuccessfully()
        
        XCTAssertTrue(loggedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageDataCacher, store: StoreSpy) {
        let store = StoreSpy()
        let sut = ImageDataCacher(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: ImageDataCacher,
                        completeWith expectedResult: Result<Void, Error>,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.save(data: anyData(), for: anyId()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success), (.failure, .failure):
                break
            default:
                XCTFail("Expect \(expectedResult), got \(receivedResult), instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
    
    private func failureWithAnyError() -> Result<Void, Error> {
        .failure(anyNSError())
    }
    
    private func anyId() -> String {
        "any id"
    }
    
    final class StoreSpy: ImageDataStore {
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
}
