//
//  NSCacheDataStore.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 01/12/2023.
//

import Foundation

final class NSCacheDataStore: ImageDataStore {
    private let cache: NSCache<NSURL, NSData>
    
    init() {
        self.cache = NSCache<NSURL, NSData>()
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertResult) -> Void) {
        cache.setObject(data as NSData, forKey: url as NSURL)
        completion(.success(()))
    }
    
    func retrieveData(for url: URL, completion: @escaping (RetrieveResult) -> Void) {
        let data = cache.object(forKey: url as NSURL) as? Data
        completion(.success(data))
    }
}
