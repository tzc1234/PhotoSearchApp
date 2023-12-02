//
//  ImageDataCacheIntegrationTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 02/12/2023.
//

import XCTest
@testable import PhotoSearchApp

final class ImageDataCacheIntegrationTests: XCTestCase {
    func test_loadData_deliversNoDataWhenNoCachedData() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: noData(), for: anyURL())
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> ImageDataCacher {
        let store = NSCacheDataStore()
        let sut = ImageDataCacher(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: ImageDataCacher,
                        toRetrieve expectedData: Data?,
                        for url: URL,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        _ = sut.loadData(for: url) { result in
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
