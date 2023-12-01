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
        let sut = NSCacheDataStore()
        
        let exp = expectation(description: "Wait for completion")
        sut.retrieveData(for: anyId()) { receivedResult in
            switch receivedResult {
            case let .success(receivedData):
                XCTAssertNil(receivedData)
            case .failure:
                XCTFail("Should not fail")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
}
