//
//  NSCacheDataStoreTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 01/12/2023.
//

import XCTest
@testable import PhotoSearchApp

final class NSCacheDataStoreTests: XCTestCase {
    func test_retrieveData_deliversNoDataWhenNoCachedData() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: noData(), for: anyKey())
    }
    
    func test_retrieveDataTwice_deliversNoDataTwiceWhenNoCachedDataWithNoSideEffects() {
        let sut = makeSUT()
        let key = anyKey()
        
        expect(sut, toRetrieve: noData(), for: key)
        expect(sut, toRetrieve: noData(), for: key)
    }
    
    func test_retrieveData_deliversCachedData() {
        let sut = makeSUT()
        let cachedData = anyData()
        let key = anyKey()
        
        insert(cachedData, for: key, into: sut)
        
        expect(sut, toRetrieve: .success(cachedData), for: key)
    }
    
    func test_retrieveDataTwice_deliversCachedDataTwiceWithNoSideEffects() {
        let sut = makeSUT()
        let cachedData = anyData()
        let key = anyKey()
        
        insert(cachedData, for: key, into: sut)
        
        expect(sut, toRetrieve: .success(cachedData), for: key)
        expect(sut, toRetrieve: .success(cachedData), for: key)
    }
    
    func test_insertData_overridesPreviousCachedData() {
        let sut = makeSUT()
        let firstCachedData = Data("first".utf8)
        let lastCachedData = Data("last".utf8)
        let key = anyKey()
        
        insert(firstCachedData, for: key, into: sut)
        insert(lastCachedData, for: key, into: sut)
        
        expect(sut, toRetrieve: .success(lastCachedData), for: key)
    }
    
    func test_operations_runsSerially() {
        let sut = makeSUT()
        
        let op1 = expectation(description: "operation 1")
        sut.insert(anyData(), for: anyKey()) { _ in op1.fulfill() }
        
        let op2 = expectation(description: "operation 2")
        sut.insert(anyData(), for: anyKey()) { _ in op2.fulfill() }
        
        let op3 = expectation(description: "operation 3")
        sut.retrieveData(for: anyKey()) { _ in op3.fulfill() }
        
        wait(for: [op1, op2, op3], timeout: 1, enforceOrder: true)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> NSCacheDataStore {
        let sut = NSCacheDataStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func insert(_ data: Data,
                        for key: String,
                        into sut: NSCacheDataStore,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for insertion completion")
        sut.insert(data, for: key) { receivedResult in
            switch receivedResult {
            case .success:
                break
            case .failure:
                XCTFail("Expect insertion successfully, got a failure instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
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
    
    private func anyKey() -> String {
        "any key"
    }
}
