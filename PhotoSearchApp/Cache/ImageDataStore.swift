//
//  ImageDataStore.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 01/12/2023.
//

import Foundation

protocol ImageDataStore {
    typealias InsertResult = Result<Void, Error>
    typealias RetrieveResult = Result<Data?, Error>
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertResult) -> Void)
    func retrieveData(for url: URL, completion: @escaping (RetrieveResult) -> Void)
}
