//
//  PhotoImageEndpointTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 22/07/2023.
//

import XCTest
@testable import PhotoSearchApp

enum PhotoImageEndpoint {
    case get(photo: Photo)
    
    private var baseURL: URL {
        URL(string: "https://live.staticflickr.com")!
    }
    
    var url: URL {
        switch self {
        case let .get(photo):
            return baseURL.appending(path: "/\(photo.server)/\(photo.id)_\(photo.secret)_b.jpg")
        }
    }
}

final class PhotoImageEndpointTests: XCTestCase {
    func test_url_getURLForPhoto() {
        let photo = makePhoto(id: "photoID", title: "any", server: "photo-server", secret: "photo-secret")
        let url = PhotoImageEndpoint.get(photo: photo).url.absoluteString
        
        XCTAssertEqual(url, "https://live.staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_b.jpg")
    }
}
