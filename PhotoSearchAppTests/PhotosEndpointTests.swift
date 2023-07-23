//
//  PhotosEndpointTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 22/07/2023.
//

import XCTest
@testable import PhotoSearchApp

final class PhotosEndpointTests: XCTestCase {
    func test_url_getURLWithNonEmptySearchTerm() {
        let apiKey = "api_key"
        let searchTerm = "search term"
        let url = PhotosEndpoint.get(searchTerm: searchTerm).url(apiKey: apiKey).absoluteString
        
        XCTAssertTrue(url.contains("https://www.flickr.com/services/rest/?"))
        XCTAssertTrue(url.contains("method=flickr.photos.search"))
        XCTAssertTrue(url.contains("safe_search=1"))
        XCTAssertTrue(url.contains("api_key=\(apiKey)"))
        XCTAssertTrue(url.contains("text=search%20term"))
        XCTAssertTrue(url.contains("format=json"))
        XCTAssertTrue(url.contains("nojsoncallback=1"))
    }
    
    func test_url_getURLWithEmptySearchTerm() {
        let apiKey = "api_key"
        let emptySearchTerm = ""
        let url = PhotosEndpoint.get(searchTerm: emptySearchTerm).url(apiKey: apiKey).absoluteString
        
        XCTAssertTrue(url.contains("https://www.flickr.com/services/rest/?"))
        XCTAssertTrue(url.contains("method=flickr.photos.getRecent"))
        XCTAssertTrue(url.contains("safe_search=1"))
        XCTAssertTrue(url.contains("api_key=\(apiKey)"))
        XCTAssertTrue(url.contains("format=json"))
        XCTAssertTrue(url.contains("nojsoncallback=1"))
    }
}
