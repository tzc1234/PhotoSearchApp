//
//  PhotosResponseConverterTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 22/07/2023.
//

import XCTest
@testable import PhotoSearchApp

enum PhotosResponseConverter {
    enum Error: Swift.Error {
        case invalidData
    }
    
    static func convert(from data: Data, response: HTTPURLResponse) throws -> [Photo] {
        guard isOK(response) else { throw Error.invalidData }
        
        do {
            let response = try JSONDecoder().decode(Response.self, from: data)
            return response.photos.photos
        } catch {
            throw Error.invalidData
        }
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        response.statusCode == 200
    }
    
    private struct Response: Decodable {
        let photos: PhotosResponse
        
        struct PhotosResponse: Decodable {
            let photo: [PhotoResponse]
            
            var photos: [Photo] {
                photo.map {
                    Photo(id: $0.id, title: $0.title, server: $0.server, secret: $0.secret)
                }
            }
        }
        
        struct PhotoResponse: Decodable {
            let id: String
            let secret: String
            let server: String
            let title: String
        }
    }
}

final class PhotosResponseConverterTests: XCTestCase {
    func test_convert_deliversErrorOnNon200Response() throws {
        let data = anyData()
        let samples = [100, 199, 201, 300, 400, 500]
        
        try samples.forEach { statusCode in
            let response = HTTPURLResponse(statusCode: statusCode)
            XCTAssertThrowsError(try PhotosResponseConverter.convert(from: data, response: response), "Expect an error at statusCode: \(statusCode)")
        }
    }
    
    func test_convert_deliversErrorOn200ResponseWithInvalidData() {
        let invalidData = Data("invalid data".utf8)
        
        XCTAssertThrowsError(try PhotosResponseConverter.convert(from: invalidData, response: okResponse()))
    }
    
    func test_convert_deliversEmptyOn200ResponseWithEmptyPhotos() throws {
        let emptyPhotosResponse = PhotosResponse(photos: .init(photo: []))
        let emptyPhotosData = try JSONEncoder().encode(emptyPhotosResponse)
        
        let photos = try PhotosResponseConverter.convert(from: emptyPhotosData, response: okResponse())
        
        XCTAssertEqual(photos, [])
    }
    
    func test_convert_deliversOnePhotoOn200ResponseWithOnePhoto() throws {
        let onePhotoResponse = PhotosResponse(photos: .init(photo: [.init(id: "id0", secret: "secret0", server: "server0", title: "title0")]))
        let onePhotoData = try JSONEncoder().encode(onePhotoResponse)
        
        let photos = try PhotosResponseConverter.convert(from: onePhotoData, response: okResponse())
        
        XCTAssertEqual(photos, [Photo(id: "id0", title: "title0", server: "server0", secret: "secret0")])
    }
    
    // MARK: - Helpers
    
    private func okResponse() -> HTTPURLResponse {
        HTTPURLResponse(statusCode: 200)
    }
    
    private struct PhotosResponse: Encodable {
        let photos: Photos
        
        struct Photos: Encodable {
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

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
