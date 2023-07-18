//
//  PhotoSearchUIIntegrationTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 18/07/2023.
//

import XCTest
@testable import PhotoSearchApp

class PhotoSearchViewController {
    init(loader: LoaderSpy) {
        
    }
}

class LoaderSpy {
    private(set) var loadCallCount = 0
}

final class PhotoSearchUIIntegrationTests: XCTestCase {

    func test_init_doesNotNotifyLoader() {
        let loader = LoaderSpy()
        _ = PhotoSearchViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }

}
