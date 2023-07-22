//
//  PhotosResponseConverter.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 22/07/2023.
//

import Foundation

enum PhotosResponseConverter {
    enum Error: Swift.Error {
        case invalidData
    }
    
    static func convert(from data: Data, response: HTTPURLResponse) throws -> [Photo] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        
        return root.photos
    }
    
    private struct Root: Decodable {
        let remotePhotos: RemotePhotos
        
        var photos: [Photo] {
            remotePhotos.photo.map {
                Photo(id: $0.id, title: $0.title, server: $0.server, secret: $0.secret)
            }
        }
        
        struct RemotePhotos: Decodable {
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
    }
}
