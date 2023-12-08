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
        
        photos.setTableHeightToLimitCellViewRendering(.heightFor(numOfCells: 2))
        
        XCTAssertEqual(photos.numberOfPhotoViews, 2)
        XCTAssertEqual(photos.photoView(at: 0)?.renderedImage, makeImageData0())
        XCTAssertEqual(photos.photoView(at: 1)?.renderedImage, makeImageData1())
        
        photos.setTableHeightToLimitCellViewRendering(.heightFor(numOfCells: 3))
        photos.simulateLoadMoreAction()
        
        XCTAssertEqual(photos.numberOfPhotoViews, 3)
        XCTAssertEqual(photos.photoView(at: 0)?.renderedImage, makeImageData0())
        XCTAssertEqual(photos.photoView(at: 1)?.renderedImage, makeImageData1())
        XCTAssertEqual(photos.photoView(at: 2)?.renderedImage, makeLoadMoreImageData0())
        
        photos.setTableHeightToLimitCellViewRendering(.heightFor(numOfCells: 99))
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
        
        photos.setTableHeightToLimitCellViewRendering(.heightFor(numOfCells: 1))
        photos.simulateSearchPhotos(by: searchKeyword())
        
        XCTAssertEqual(photos.numberOfPhotoViews, 1)
        XCTAssertEqual(photos.photoView(at: 0)?.renderedImage, makeSearchedImageData())
        
        photos.setTableHeightToLimitCellViewRendering(.heightFor(numOfCells: 2))
        photos.simulateLoadMoreAction()
        
        XCTAssertEqual(photos.numberOfPhotoViews, 2)
        XCTAssertEqual(photos.photoView(at: 0)?.renderedImage, makeSearchedImageData())
        XCTAssertEqual(photos.photoView(at: 1)?.renderedImage, makeLoadMoreImageData0())
        
        photos.setTableHeightToLimitCellViewRendering(.heightFor(numOfCells: 99))
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
        vc.simulateAppearance(tableViewFrame: .init(x: 0, y: 0, width: 390, height: 1))
        
        return vc
    }
    
    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        (makeData(for: url), ok200Response())
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.path() {
        case "/services/rest/"
            where url.query()?.contains("text=\(searchKeyword())") == true && url.query()?.contains("page=1") == true:
            return makeSearchedPhotosData()
            
        case "/services/rest/" where url.query()?.contains("page=3") == true:
            return makePage3PhotosData()
            
        case "/services/rest/" where url.query()?.contains("page=1") == true:
            return makePage1PhotosData()
            
        case "/services/rest/" where url.query()?.contains("page=2") == true:
            return makePage2PhotosData()
            
        case "/page1Server1/page1Id1_page1Secret1_b.jpg":
            return makeImageData0()
            
        case "/page1Server2/page1Id2_page1Secret2_b.jpg":
            return makeImageData1()
            
        case "/searchedServer/searchedId_searchedSecret_b.jpg":
            return makeSearchedImageData()
            
        case "/page2Server/page2Id_page2Secret_b.jpg":
            return makeLoadMoreImageData0()
            
        case "/page3Server/page3Id_page3Secret_b.jpg":
            return makeLoadMoreImageData1()
            
        default:
            return Data()
        }
    }
    
    private func makePage1PhotosData() -> Data {
        let json: [String: Any] = [
            "photos": [
                "page": 1,
                "pages": 3,
                "photo": [
                    [
                        "id": "page1Id1",
                        "secret": "page1Secret1",
                        "server": "page1Server1",
                        "title": "page1Title1"
                    ],
                    [
                        "id": "page1Id2",
                        "secret": "page1Secret2",
                        "server": "page1Server2",
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

private extension CGFloat {
    static func heightFor(numOfCells num: CGFloat) -> CGFloat {
        PhotoCell.cellHeight * CGFloat(num)
    }
}
