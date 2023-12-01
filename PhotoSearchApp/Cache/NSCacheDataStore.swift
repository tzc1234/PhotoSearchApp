//
//  NSCacheDataStore.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 01/12/2023.
//

import Foundation

final class NSCacheDataStore: ImageDataStore {
    private let cache: NSCache<NSString, NSData>
    
    init() {
        self.cache = NSCache<NSString, NSData>()
    }
    
    func insert(_ data: Data, for key: String, completion: @escaping (InsertResult) -> Void) {
        cache.setObject(data as NSData, forKey: key as NSString)
        completion(.success(()))
    }
    
    func retrieveData(for key: String, completion: @escaping (RetrieveResult) -> Void) {
        let data = cache.object(forKey: key as NSString) as? Data
        completion(.success(data))
    }
}
