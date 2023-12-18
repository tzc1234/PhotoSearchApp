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
        
        photos.simulateLoadMoreAction()
        
        XCTAssertEqual(photos.numberOfPhotoViews, 3)
        XCTAssertEqual(photos.photoView(at: 0)?.renderedImage, makeImageData0())
        XCTAssertEqual(photos.photoView(at: 1)?.renderedImage, makeImageData1())
        XCTAssertEqual(photos.photoView(at: 2)?.renderedImage, makeLoadMoreImageData0())
        
        photos.simulateLoadMoreAction()
        
        XCTAssertEqual(photos.numberOfPhotoViews, 4)
        XCTAssertEqual(photos.photoView(at: 0)?.renderedImage, makeImageData0())
        XCTAssertEqual(photos.photoView(at: 1)?.renderedImage, makeImageData1())
        XCTAssertEqual(photos.photoView(at: 2)?.renderedImage, makeLoadMoreImageData0())
        XCTAssertEqual(photos.photoView(at: 3)?.renderedImage, makeLoadMoreImageData1())
        XCTAssertTrue(photos.isLastPage)
    }
    
    func test_onLaunch_displaysPhotosWhenUserHasConnectivityWithSearchKeyword() throws {
        let photos = try onLaunch(.online(response))
        
        photos.simulateSearchPhotos(by: searchKeyword())
        
        XCTAssertEqual(photos.numberOfPhotoViews, 1)
        XCTAssertEqual(photos.photoView(at: 0)?.renderedImage, makeSearchedImageData())
        
        photos.simulateLoadMoreAction()
        
        XCTAssertEqual(photos.numberOfPhotoViews, 2)
        XCTAssertEqual(photos.photoView(at: 0)?.renderedImage, makeSearchedImageData())
        XCTAssertEqual(photos.photoView(at: 1)?.renderedImage, makeLoadMoreImageData0())
        
        photos.simulateLoadMoreAction()
        
        XCTAssertEqual(photos.numberOfPhotoViews, 3)
        XCTAssertEqual(photos.photoView(at: 0)?.renderedImage, makeSearchedImageData())
        XCTAssertEqual(photos.photoView(at: 1)?.renderedImage, makeLoadMoreImageData0())
        XCTAssertEqual(photos.photoView(at: 2)?.renderedImage, makeLoadMoreImageData1())
        XCTAssertTrue(photos.isLastPage)
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
        case "/services/rest/"
            where queryContains(keyword: searchKeyword(), in: url) && queryContains(page: 1, in: url):
            return makeSearchedPhotosData()
            
        case "/services/rest/" where queryContains(page: 3, in: url):
            return makePage3PhotosData()
            
        case "/services/rest/" where queryContains(page: 1, in: url):
            return makePage1PhotosData()
            
        case "/services/rest/" where queryContains(page: 2, in: url):
            return makePage2PhotosData()
            
        case makeImageDataPath(id: "page1Id1", secret: "page1Secret", server: "page1Server"):
            return makeImageData0()
            
        case makeImageDataPath(id: "page1Id2", secret: "page1Secret", server: "page1Server"):
            return makeImageData1()
            
        case makeImageDataPath(id: "searchedId", secret: "searchedSecret", server: "searchedServer"):
            return makeSearchedImageData()
            
        case makeImageDataPath(id: "page2Id", secret: "page2Secret", server: "page2Server"):
            return makeLoadMoreImageData0()
            
        case makeImageDataPath(id: "page3Id", secret: "page3Secret", server: "page3Server"):
            return makeLoadMoreImageData1()
            
        default:
            return Data()
        }
    }
    
    private func queryContains(keyword: String, in url: URL) -> Bool {
        queryContains("text=\(keyword)", in: url)
    }
    
    private func queryContains(page: Int, in url: URL) -> Bool {
        queryContains("page=\(page)", in: url)
    }
    
    private func queryContains(_ str: String, in url: URL) -> Bool {
        url.query()?.contains(str) == true
    }
    
    private func makeImageDataPath(id: String, secret: String, server: String) -> String {
        "/\(server)/\(id)_\(secret)_b.jpg"
    }
    
    private func makePage1PhotosData() -> Data {
        let json: [String: Any] = [
            "photos": [
                "page": 1,
                "pages": 3,
                "photo": [
                    [
                        "id": "page1Id1",
                        "secret": "page1Secret",
                        "server": "page1Server",
                        "title": "page1Title1"
                    ],
                    [
                        "id": "page1Id2",
                        "secret": "page1Secret",
                        "server": "page1Server",
                        "title": "page1Title2"
                    ],
                ]
            ]
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makePage2PhotosData() -> Data {
        let json: [String: Any] = [
            "photos": [
                "page": 2,
                "pages": 3,
                "photo": [
                    [
                        "id": "page2Id",
                        "secret": "page2Secret",
                        "server": "page2Server",
                        "title": "page2Title"
                    ]
                ]
            ]
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makePage3PhotosData() -> Data {
        let json: [String: Any] = [
            "photos": [
                "page": 3,
                "pages": 3,
                "photo": [
                    [
                        "id": "page3Id",
                        "secret": "page3Secret",
                        "server": "page3Server",
                        "title": "page3Title"
                    ]
                ]
            ]
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeSearchedPhotosData() -> Data {
        let json: [String: Any] = [
            "photos": [
                "page": 1,
                "pages": 3,
                "photo": [
                    [
                        "id": "searchedId",
                        "secret": "searchedSecret",
                        "server": "searchedServer",
                        "title": "searchedTitle"
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
    
    private func makeLoadMoreImageData0() -> Data {
        UIImage.makeData(withColor: .lightGray)
    }
    
    private func makeLoadMoreImageData1() -> Data {
        UIImage.makeData(withColor: .darkGray)
    }
    
    private func searchKeyword() -> String {
        "keyword"
    }
}
