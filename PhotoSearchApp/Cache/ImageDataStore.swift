//
//  ImageDataStore.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 01/12/2023.
//

import Foundation

protocol ImageDataStore {
    typealias InsertResult = Result<Void, Error>
    
    func insert(_ data: Data, for key: String, completion: @escaping (InsertResult) -> Void)
}
