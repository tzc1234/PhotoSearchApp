//
//  ImageDataStore.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 01/12/2023.
//

import Foundation

protocol ImageDataStore {
    func insert(data: Data, for key: String, completion: @escaping (Result<Void, Error>) -> Void)
}
