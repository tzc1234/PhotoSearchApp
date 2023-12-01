//
//  LoadImageDataFromCacheUseCaseTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 01/12/2023.
//

import XCTest
@testable import PhotoSearchApp

final class LoadImageDataFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_loadData_requestsCachedDataForId() {
        let (sut, store) = makeSUT()
        let id = "image id"
        
        sut.loadData(for: id) { _ in }
        
        XCTAssertEqual(store.messages, [.retrieveData(for: id)])
    }
    
    func test_loadData_deliversErrorOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, completeWith: failureWithAnyError(), when: {
            store.completeRetrievalWithError()
        })
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
                        completeWith expectedResult: ImageDataCacher.LoadResult,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.loadData(for: anyId()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expect \(expectedResult), got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
    
    private func failureWithAnyError() -> ImageDataCacher.LoadResult {
        .failure(anyNSError())
    }
    
    private func anyId() -> String {
        "any id"
    }
}
