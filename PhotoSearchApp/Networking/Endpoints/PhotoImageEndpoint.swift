//
//  PhotoImageEndpoint.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 22/07/2023.
//

import Foundation

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
