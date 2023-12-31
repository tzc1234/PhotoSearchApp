//
//  ImageDataCacheIntegrationTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 02/12/2023.
//

import XCTest
@testable import PhotoSearchApp

final class ImageDataCacheIntegrationTests: XCTestCase {
    func test_loadData_deliversCachedData() {
        let sut = makeSUT()
        let cachedData = anyData()
        let url = anyURL()
        
        save(cachedData, for: url, into: sut)
        
        expect(sut, toLoad: cachedData, for: url)
    }
    
    func test_saveData_overridesPerviousCachedData() {
        let sut = makeSUT()
        let firstCachedData = Data("first".utf8)
        let lastCachedData = Data("last".utf8)
        let url = anyURL()
        
        save(firstCachedData, for: url, into: sut)
        save(lastCachedData, for: url, into: sut)
        
        expect(sut, toLoad: lastCachedData, for: url)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> ImageDataCacher {
        let store = NSCacheDataStore()
        let sut = ImageDataCacher(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func save(_ data: Data,
                        for url: URL,
                        into sut: ImageDataCacher,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.save(data, for: url) { receivedResult in
            switch receivedResult {
            case .success:
                break
            case .failure:
                XCTFail("Expect save successfully, got a failure instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    private func expect(_ sut: ImageDataCacher,
                        toLoad expectedData: Data?,
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
}
