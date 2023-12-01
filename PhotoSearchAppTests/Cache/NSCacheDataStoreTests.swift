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
        
        expect(sut, toRetrieve: noData(), for: anyURL())
    }
    
    func test_retrieveDataTwice_deliversNoDataTwiceWhenNoCachedDataWithNoSideEffects() {
        let sut = makeSUT()
        let url = anyURL()
        
        expect(sut, toRetrieve: noData(), for: url)
        expect(sut, toRetrieve: noData(), for: url)
    }
    
    func test_retrieveData_deliversCachedData() {
        let sut = makeSUT()
        let cachedData = anyData()
        let url = anyURL()
        
        insert(cachedData, for: url, into: sut)
        
        expect(sut, toRetrieve: cachedData, for: url)
    }
    
    func test_retrieveDataTwice_deliversCachedDataTwiceWithNoSideEffects() {
        let sut = makeSUT()
        let cachedData = anyData()
        let url = anyURL()
        
        insert(cachedData, for: url, into: sut)
        
        expect(sut, toRetrieve: cachedData, for: url)
        expect(sut, toRetrieve: cachedData, for: url)
    }
    
    func test_insertData_overridesPreviousCachedData() {
        let sut = makeSUT()
        let firstCachedData = Data("first".utf8)
        let lastCachedData = Data("last".utf8)
        let url = anyURL()
        
        insert(firstCachedData, for: url, into: sut)
        insert(lastCachedData, for: url, into: sut)
        
        expect(sut, toRetrieve: lastCachedData, for: url)
    }
    
    func test_operations_runsSerially() {
        let sut = makeSUT()
        
        let op1 = expectation(description: "operation 1")
        sut.insert(anyData(), for: anyURL()) { _ in op1.fulfill() }
        
        let op2 = expectation(description: "operation 2")
        sut.insert(anyData(), for: anyURL()) { _ in op2.fulfill() }
        
        let op3 = expectation(description: "operation 3")
        sut.retrieveData(for: anyURL()) { _ in op3.fulfill() }
        
        wait(for: [op1, op2, op3], timeout: 1, enforceOrder: true)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> NSCacheDataStore {
        let sut = NSCacheDataStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func insert(_ data: Data,
                        for url: URL,
                        into sut: NSCacheDataStore,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for insertion completion")
        sut.insert(data, for: url) { receivedResult in
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
                        toRetrieve expectedData: Data?,
                        for url: URL,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval completion")
        sut.retrieveData(for: url) { result in
            switch result {
            case let .success(data):
                XCTAssertEqual(data, expectedData, file: file, line: line)
            case let .failure(error):
                XCTFail("Expect \(String(describing: expectedData)), got \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    private func noData() -> Data? {
        nil
    }
}
