//
//  PhotosEndpointTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 22/07/2023.
//

import XCTest

enum PhotosEndpoint {
    case get(searchTerm: String)
    
    func url(apiKey: String) -> URL {
        switch self {
        case let .get(searchTerm):
            var components = URLComponents()
            components.scheme = "https"
            components.host = "www.flickr.com"
            components.path = "/services/rest/"
            components.queryItems = [
                .init(name: "method", value: "flickr.photos.search"),
                .init(name: "api_key", value: apiKey),
                .init(name: "text", value: searchTerm),
                .init(name: "format", value: "json"),
                .init(name: "nojsoncallback", value: "1")
            ]
            return components.url!
        }
    }
}

final class PhotosEndpointTests: XCTestCase {
    func test_url_getURL() {
        let apiKey = "api_key"
        let searchTerm = "search term"
        let url = PhotosEndpoint.get(searchTerm: searchTerm).url(apiKey: apiKey).absoluteString
        
        XCTAssertTrue(url.contains("https://www.flickr.com/services/rest/?"))
        XCTAssertTrue(url.contains("method=flickr.photos.search"))
        XCTAssertTrue(url.contains("api_key=\(apiKey)"))
        XCTAssertTrue(url.contains("text=search%20term"))
        XCTAssertTrue(url.contains("format=json"))
        XCTAssertTrue(url.contains("nojsoncallback=1"))
    }
}
