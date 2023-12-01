//
//  CacheImageDataUseCaseTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 01/12/2023.
//

import XCTest
@testable import PhotoSearchApp

final class CacheImageDataUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_saveData_requestsStoreCachingWithDataAndId() {
        let (sut, store) = makeSUT()
        let data = Data("save data".utf8)
        let url = URL(string: "https://a-url.com")!
        
        sut.save(data, for: url) { _ in }
        
        XCTAssertEqual(store.messages, [.insert(data, for: url)])
    }
    
    func test_saveData_deliversErrorOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, completeWith: failureWithAnyError(), when: {
            store.completeInsertionWithError()
        })
    }
    
    func test_saveData_deliversNoErrorOnCachingSuccessfully() {
        let (sut, store) = makeSUT()
        
        expect(sut, completeWith: .success(()), when: {
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_saveData_doesNotDeliverResultWhenSUTIsDeallocated() {
        let store = ImageDataStoreSpy()
        var sut: ImageDataCacher? = ImageDataCacher(store: store)
        
        var loggedResults = [ImageDataCacher.SaveResult]()
        sut?.save(anyData(), for: anyURL()) { loggedResults.append($0) }
        
        sut = nil
        store.completeInsertionSuccessfully()
        
        XCTAssertTrue(loggedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageDataCacher, store: ImageDataStoreSpy) {
        let store = ImageDataStoreSpy()
        let sut = ImageDataCacher(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: ImageDataCacher,
                        completeWith expectedResult: ImageDataCacher.SaveResult,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.save(anyData(), for: anyURL()) { receivedResult in
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
    
    private func failureWithAnyError() -> ImageDataCacher.SaveResult {
        .failure(anyNSError())
    }
}
