//
//  PhotosResponseConverter.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 22/07/2023.
//

import Foundation

enum PhotosResponseConverter {
    private struct Root: Decodable {
        let remotePhotos: RemotePhotos
        
        struct RemotePhotos: Decodable {
            let page: Int
            let pages: Int
            let photo: [RemotePhoto]
        }
        
        struct RemotePhoto: Decodable {
            let id: String
            let secret: String
            let server: String
            let title: String
        }
        
        enum CodingKeys: String, CodingKey {
            case remotePhotos = "photos"
        }
        
        var photos: [Photo] {
            remotePhotos.photo.map {
                Photo(id: $0.id, title: $0.title, server: $0.server, secret: $0.secret)
            }
        }
        
        var hasNextPage: Bool {
            remotePhotos.page < remotePhotos.pages
        }
    }
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    static func convert(_ data: Data, response: HTTPURLResponse) throws -> (photos: [Photo], hasNextPage: Bool) {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        
        return (root.photos, root.hasNextPage)
    }
}
