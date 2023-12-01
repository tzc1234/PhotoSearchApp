//
//  NSCacheDataStoreTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 01/12/2023.
//

import XCTest
@testable import PhotoSearchApp

final class NSCacheDataStore {
    init() {
        
    }
    
    func retrieveData(for key: String, completion: @escaping (ImageDataStore.RetrieveResult) -> Void) {
        completion(.success(nil))
    }
}

final class NSCacheDataStoreTests: XCTestCase {
    func test_retrieveData_deliversNoDataWhenNoCachedData() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: noData(), for: anyId())
    }
    
    func test_retrieveDataTwice_deliversNoDataTwiceWhenNoCachedDataWithNoSideEffects() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: noData(), for: anyId())
        expect(sut, toRetrieve: noData(), for: anyId())
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> NSCacheDataStore {
        let sut = NSCacheDataStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: NSCacheDataStore,
                        toRetrieve expectedResult: ImageDataStore.RetrieveResult,
                        for key: String,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval completion")
        sut.retrieveData(for: key) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expect \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    private func noData() -> ImageDataStore.RetrieveResult {
        .success(nil)
    }
}
