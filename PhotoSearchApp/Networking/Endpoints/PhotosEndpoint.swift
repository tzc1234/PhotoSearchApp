//
//  PhotosEndpoint.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 22/07/2023.
//

import Foundation

enum PhotosEndpoint {
    case get(searchTerm: String, page: Int)
    
    func url(apiKey: String) -> URL {
        switch self {
        case let .get(searchTerm, page):
            var components = URLComponents()
            components.scheme = "https"
            components.host = "www.flickr.com"
            components.path = "/services/rest/"
            components.queryItems = [
                .init(name: "method", value: "flickr.photos.\(searchTerm.isEmpty ? "getRecent" : "search")"),
                .init(name: "safe_search", value: "1"),
                .init(name: "api_key", value: apiKey),
                .init(name: "text", value: searchTerm),
                .init(name: "format", value: "json"),
                .init(name: "nojsoncallback", value: "1"),
                .init(name: "page", value: "\(page)"),
                .init(name: "per_page", value: "20")
            ]
            return components.url!
        }
    }
}
