//
//  NSCacheDataStoreTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 01/12/2023.
//

import XCTest
@testable import PhotoSearchApp

final class NSCacheDataStore {
    private let cache: NSCache<NSString, NSData>
    
    init() {
        self.cache = NSCache<NSString, NSData>()
    }
    
    func insert(_ data: Data, for key: String, completion: @escaping (ImageDataStore.InsertResult) -> Void) {
        cache.setObject(data as NSData, forKey: key as NSString)
        completion(.success(()))
    }
    
    func retrieveData(for key: String, completion: @escaping (ImageDataStore.RetrieveResult) -> Void) {
        let data = cache.object(forKey: key as NSString) as? Data
        completion(.success(data))
    }
}

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
