//
//  PhotoImageEndpointTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 22/07/2023.
//

import XCTest
@testable import PhotoSearchApp

final class PhotoImageEndpointTests: XCTestCase {
    func test_url_getURLForPhoto() {
        let photo = makePhoto(id: "photoID", title: "any", server: "photo-server", secret: "photo-secret")
        let url = PhotoImageEndpoint.get(photo: photo).url.absoluteString
        
        XCTAssertEqual(url, "https://live.staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_b.jpg")
    }
}
