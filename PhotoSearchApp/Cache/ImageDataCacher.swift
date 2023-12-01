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
    
    typealias SaveResult = Result<Void, Error>
    
    func save(_ data: Data, for id: String, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: id) { [weak self] result in
            guard self != nil else { return }
            
            completion(result)
        }
    }
    
    typealias LoadResult = Result<Data?, Error>
    
    func loadData(for id: String, completion: @escaping (LoadResult) -> Void) {
        store.retrieveData(for: id, completion: completion)
    }
}
