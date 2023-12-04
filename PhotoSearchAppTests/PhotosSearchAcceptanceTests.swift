//
//  PhotosSearchAcceptanceTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 04/12/2023.
//

import XCTest
@testable import PhotoSearchApp

final class PhotosSearchAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysPhotosWhenUserHasConnectivity() throws {
        let httpClientStub = HTTPClientStub(stub: { .success(self.response(for: $0)) })
        let sceneDelegate = SceneDelegate(httpClient: httpClientStub)
        let window = UIWindow()
        sceneDelegate.window = window
        sceneDelegate.configureWindow()
        
        let nav = try XCTUnwrap(window.rootViewController as? UINavigationController)
        let photos = try XCTUnwrap(nav.topViewController as? PhotoSearchViewController)
        photos.simulateAppearance()
        
        XCTAssertEqual(photos.numberOfPhotoViews, 2)
        XCTAssertEqual(photos.photoView(at: 0)?.renderedImage, makeImageData0())
        XCTAssertEqual(photos.photoView(at: 1)?.renderedImage, makeImageData1())
    }
    
    func test_onLunch_displaysPhotosWhenUserHasConnectivityAndSearchesByKeyword() throws {
        let httpClientStub = HTTPClientStub(stub: { .success(self.response(for: $0)) })
        let sceneDelegate = SceneDelegate(httpClient: httpClientStub)
        let window = UIWindow()
        sceneDelegate.window = window
        sceneDelegate.configureWindow()
        
        let nav = try XCTUnwrap(window.rootViewController as? UINavigationController)
        let photos = try XCTUnwrap(nav.topViewController as? PhotoSearchViewController)
        photos.simulateAppearance()
        photos.simulateSearchPhotos(by: searchKeyword())
        RunLoop.current.run(until: .now)
        
        XCTAssertEqual(photos.numberOfPhotoViews, 1)
        XCTAssertEqual(photos.photoView(at: 0)?.renderedImage, makeSearchedImageData())
    }
    
    // MARK: - Helpers
    
    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        (makeData(for: url), ok200Response())
    }
    
    private func makeData(for url: URL) -> Data {
        print("url: \(url)")
        switch url.path() {
        case "/services/rest/" where url.query()?.contains("text=\(searchKeyword())") == true:
            return makeSearchedPhotosData()
            
        case "/services/rest/":
            return makePhotosData()
            
        case "/server0/id0_secret0_b.jpg":
            return makeImageData0()
            
        case "/server1/id1_secret1_b.jpg":
            return makeImageData1()
            
        case "/server2/id2_secret2_b.jpg":
            return makeSearchedImageData()
            
        default:
            return Data()
        }
    }
    
    private func makePhotosData() -> Data {
        let json: [String: Any] = [
            "photos": [
                "photo": [
                    [
                        "id": "id0",
                        "secret": "secret0",
                        "server": "server0",
                        "title": "title0"
                    ],
                    [
                        "id": "id1",
                        "secret": "secret1",
                        "server": "server1",
                        "title": "title1"
                    ],
                ]
            ]
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeSearchedPhotosData() -> Data {
        let json: [String: Any] = [
            "photos": [
                "photo": [
                    [
                        "id": "id2",
                        "secret": "secret2",
                        "server": "server2",
                        "title": "title2"
                    ]
                ]
            ]
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeImageData0() -> Data {
        UIImage.makeData(withColor: .red)
    }
    
    private func makeImageData1() -> Data {
        UIImage.makeData(withColor: .green)
    }
    
    private func makeSearchedImageData() -> Data {
        UIImage.makeData(withColor: .blue)
    }
    
    private func searchKeyword() -> String {
        "keyword"
    }
    
    final class HTTPClientStub: HTTPClient {
        private let stub: (URL) -> HTTPClient.Result
        
        init(stub: @escaping (URL) -> HTTPClient.Result) {
            self.stub = stub
        }
        
        private struct Task: HTTPClientTask {
            func cancel() {}
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            completion(stub(url))
            return Task()
        }
    }
}
