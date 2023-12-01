//
//  ImageDataCacher.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 01/12/2023.
//

import Foundation

final class ImageDataCacher {
    private let store: ImageDataStore
    
    init(store: ImageDataStore) {
        self.store = store
    }
    
    func save(data: Data, for id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        store.insert(data: data, for: id) { [weak self] result in
            guard self != nil else { return }
            
            completion(result)
        }
    }
}
