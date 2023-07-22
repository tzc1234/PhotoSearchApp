//
//  PhotosEndpoint.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 22/07/2023.
//

import Foundation

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
