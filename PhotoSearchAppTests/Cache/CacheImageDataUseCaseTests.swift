//
//  CacheImageDataUseCaseTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 01/12/2023.
//

import XCTest

final class ImageDataCacher {
    init(store: StoreSpy) {
        
    }
}

final class StoreSpy {
    private(set) var messages = [Any]()
}

final class CacheImageDataUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let store = StoreSpy()
        _ = ImageDataCacher(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
}
