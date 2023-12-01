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
        
        _ = sut.loadData(for: id) { _ in }
        
        XCTAssertEqual(store.messages, [.retrieveData(for: id)])
    }
    
    func test_loadData_deliversErrorOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, completeWith: failureWithAnyError(), when: {
            store.completeRetrievalWithError()
        })
    }
    
    func test_loadData_deliversNoDataWhenNoCachedData() {
        let (sut, store) = makeSUT()
        
        expect(sut, completeWith: .success(nil), when: {
            store.completeRetrievalWithNoData()
        })
    }
    
    func test_loadData_deliversCachedDataWhenCachedDataFoundInStore() {
        let (sut, store) = makeSUT()
        let cachedData = Data("cached data".utf8)
        
        expect(sut, completeWith: .success(cachedData), when: {
            store.completeRetrieval(with: cachedData)
        })
    }
    
    func test_loadData_doesNotDeliverResultAfterCancellingLoadDataTask() {
        let (sut, store) = makeSUT()
        
        var loggedResults = [ImageDataCacher.LoadResult]()
        let task = sut.loadData(for: anyId()) { loggedResults.append($0) }
        
        task.cancel()
        store.completeRetrieval(with: anyData())
        store.completeRetrievalWithNoData()
        store.completeRetrievalWithError()
        
        XCTAssertTrue(loggedResults.isEmpty)
    }
    
    func test_saveData_doesNotDeliverResultWhenSUTIsDeallocated() {
        let store = ImageDataStoreSpy()
        var sut: ImageDataCacher? = ImageDataCacher(store: store)
        
        var loggedResults = [ImageDataCacher.LoadResult]()
        _ = sut?.loadData(for: anyId()) { loggedResults.append($0) }
        
        sut = nil
        store.completeRetrieval(with: anyData())
        
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
                        completeWith expectedResult: ImageDataCacher.LoadResult,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        _ = sut.loadData(for: anyId()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
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
