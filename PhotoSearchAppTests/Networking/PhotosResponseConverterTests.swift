//
//  PhotosResponseConverterTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 22/07/2023.
//

import XCTest
@testable import PhotoSearchApp

final class PhotosResponseConverterTests: XCTestCase {
    func test_convert_deliversErrorOnNon200Response() throws {
        let data = anyData()
        let samples = [100, 199, 201, 300, 400, 500]
        
        try samples.forEach { statusCode in
            let response = HTTPURLResponse(statusCode: statusCode)
            XCTAssertThrowsError(
                try PhotosResponseConverter.convert(data, response: response),
                "Expect an error at statusCode: \(statusCode)")
        }
    }
    
    func test_convert_deliversErrorOn200ResponseWithInvalidData() {
        let invalidData = Data("invalid data".utf8)
        
        XCTAssertThrowsError(try PhotosResponseConverter.convert(invalidData, response: ok200Response()))
    }
    
    func test_convertPhotos_deliversEmptyOn200ResponseWithEmptyPhotos() throws {
        let emptyPhotosData = makeData(from: [])
        
        let photos = try PhotosResponseConverter.convert(emptyPhotosData, response: ok200Response()).photos
        
        XCTAssertEqual(photos, [])
    }
    
    func test_convertPhotos_deliversOnePhotoOn200ResponseWithOnePhotoData() throws {
        let photo = Photo(id: "id0", title: "title0", server: "server0", secret: "secret0")
        let onePhotoData = makeData(from: [photo])
        
        let photos = try PhotosResponseConverter.convert(onePhotoData, response: ok200Response()).photos
        
        XCTAssertEqual(photos, [photo])
    }
    
    func test_convertPhotos_deliversMultiplePhotosOn200ResponseWithMultiplePhotosData() throws {
        let expectedPhotos = [
            Photo(id: "id0", title: "title0", server: "server0", secret: "secret0"),
            Photo(id: "id1", title: "title1", server: "server1", secret: "secret1"),
            Photo(id: "id2", title: "title2", server: "server2", secret: "secret2")
        ]
        let multiplePhotosData = makeData(from: expectedPhotos)
        
        let photos = try PhotosResponseConverter.convert(multiplePhotosData, response: ok200Response()).photos
        
        XCTAssertEqual(photos, expectedPhotos)
    }
    
    func test_convertHasNextPage_deliversNoHasNextPageWhenPageEqualToPages() throws {
        let pageEqualToPagesData = makeData(from: [], page: 1, pages: 1)
        
        let hasNextPage = try PhotosResponseConverter.convert(
            pageEqualToPagesData,
            response: ok200Response()).hasNextPage
        
        XCTAssertFalse(hasNextPage)
    }
    
    func test_convertHasNextPage_deliversNoHasNextPageWhenPageGreaterThanPages() throws {
        let pageGreaterThanPagesData = makeData(from: [], page: 2, pages: 1)
        
        let hasNextPage = try PhotosResponseConverter.convert(
            pageGreaterThanPagesData,
            response: ok200Response()).hasNextPage
        
        XCTAssertFalse(hasNextPage)
    }
    
    func test_convertHasNextPage_deliversHasNextPageWhenPageIsLessThanPages() throws {
        let pageLessThanPagesData = makeData(from: [], page: 1, pages: 2)
        
        let hasNextPage = try PhotosResponseConverter.convert(
            pageLessThanPagesData,
            response: ok200Response()).hasNextPage
        
        XCTAssertTrue(hasNextPage)
    }
    
    // MARK: - Helpers
    
    private func makeData(from photos: [Photo], page: Int = 1, pages: Int = 1) -> Data {
        let photoResponses = photos.map { photo in
            PhotosResponse.Photo(id: photo.id, secret: photo.secret, server: photo.server, title: photo.title)
        }
        let response = PhotosResponse(photos: .init(page: page, pages: pages, photo: photoResponses))
        return try! JSONEncoder().encode(response)
    }
    
    private struct PhotosResponse: Encodable {
        let photos: Photos
        
        struct Photos: Encodable {
            let page: Int
            let pages: Int
            let photo: [Photo]
        }
        
        struct Photo: Encodable {
            let id: String
            let secret: String
            let server: String
            let title: String
        }
    }
}
