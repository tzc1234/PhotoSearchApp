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
        let photos = try onLaunch(.online(response))
        
        XCTAssertEqual(photos.numberOfPhotoViews, 2)
        XCTAssertEqual(photos.photoView(at: 0)?.renderedImage, makeImageData0())
        XCTAssertEqual(photos.photoView(at: 1)?.renderedImage, makeImageData1())
    }
    
    func test_onLaunch_displaysPhotosWhenUserHasConnectivityAndSearchesByKeyword() throws {
        let photos = try onLaunch(.online(response))
        
        photos.simulateSearchPhotos(by: searchKeyword())
        
        XCTAssertEqual(photos.numberOfPhotoViews, 1)
        XCTAssertEqual(photos.photoView(at: 0)?.renderedImage, makeSearchedImageData())
    }
    
    func test_onLaunch_displaysErrorMessageWhenUserHasNoConnectivity() throws {
        let photos = try onLaunch(.offline)
        
        let alert = try XCTUnwrap(photos.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.title, PhotosPresenter.errorTitle)
        XCTAssertEqual(alert.message, PhotosPresenter.errorMessage)
        XCTAssertEqual(photos.numberOfPhotoViews, 0)
        
        let exp = expectation(description: "Wait for alert dismissed")
        var alertAfterSearch: UIAlertController?
        let keyword = searchKeyword()
        alert.dismiss(animated: false, completion: {
            photos.simulateSearchPhotos(by: keyword)
            
            alertAfterSearch = photos.presentedViewController as? UIAlertController
            
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1)
        
        XCTAssertNotIdentical(alert, alertAfterSearch)
        XCTAssertEqual(alertAfterSearch?.title, PhotosPresenter.errorTitle)
        XCTAssertEqual(alertAfterSearch?.message, PhotosPresenter.errorMessage)
        XCTAssertEqual(photos.numberOfPhotoViews, 0)
    }
    
    // MARK: - Helpers
    
    private func onLaunch(_ stub: HTTPClientStub) throws -> PhotoSearchViewController {
        let sceneDelegate = SceneDelegate(httpClient: stub)
        let window = UIWindow()
        sceneDelegate.window = window
        sceneDelegate.configureWindow()
        
        let nav = try XCTUnwrap(window.rootViewController as? UINavigationController)
        let vc = try XCTUnwrap(nav.topViewController as? PhotoSearchViewController)
        vc.simulateAppearance()
        
        return vc
    }
    
    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        (makeData(for: url), ok200Response())
    }
    
    private func makeData(for url: URL) -> Data {
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
}
