//
//  HTTPClient.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 21/07/2023.
//

import Foundation

protocol HTTPClientTask {
    func cancel()
}

protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) -> HTTPClientTask
}
