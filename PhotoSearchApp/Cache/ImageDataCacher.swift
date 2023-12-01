//
//  ImageDataCacher.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 01/12/2023.
//

import Foundation

protocol ImageDataCacherTask {
    func cancel()
}

final class ImageDataCacher {
    private let store: ImageDataStore
    
    init(store: ImageDataStore) {
        self.store = store
    }
}

extension ImageDataCacher {
    typealias SaveResult = Result<Void, Error>
    
    func save(_ data: Data, for id: String, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: id) { [weak self] result in
            guard self != nil else { return }
            
            completion(result)
        }
    }
}

extension ImageDataCacher {
    typealias LoadResult = Result<Data?, Error>
    
    private class TaskWrapper: ImageDataCacherTask {
        private var completion: ((LoadResult) -> Void)?
        
        init(_ completion: (@escaping (LoadResult) -> Void)) {
            self.completion = completion
        }
        
        func complete(with result: LoadResult) {
            completion?(result)
        }
        
        func cancel() {
            completion = nil
        }
    }
    
    func loadData(for id: String, completion: @escaping (LoadResult) -> Void) -> ImageDataCacherTask {
        let task = TaskWrapper(completion)
        store.retrieveData(for: id) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result)
        }
        return task
    }
}
