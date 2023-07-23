//
//  SceneDelegateTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 23/07/2023.
//

import XCTest
@testable import PhotoSearchApp

final class SceneDelegateTests: XCTestCase {
    func test_configureWindow_makesItKeyAndVisible() {
        let sut = SceneDelegate()
        let windowSpy = WindowSpy()
        sut.window = windowSpy
        
        XCTAssertEqual(windowSpy.keyAndVisibleCallCount, 0)
        
        sut.configureWindow()
        
        XCTAssertEqual(windowSpy.keyAndVisibleCallCount, 1)
    }
    
    func test_configureWindow_setsRootViewController() throws {
        let sut = SceneDelegate()
        let windowSpy = WindowSpy()
        sut.window = windowSpy
        
        sut.configureWindow()
        
        let root = try XCTUnwrap(windowSpy.rootViewController as? UINavigationController)
        XCTAssertTrue(root.topViewController is PhotoSearchViewController)
    }
    
    // MARK: - Helpers
    
    private class WindowSpy: UIWindow {
        private(set) var keyAndVisibleCallCount = 0
        
        override func makeKeyAndVisible() {
            keyAndVisibleCallCount += 1
        }
    }
}
