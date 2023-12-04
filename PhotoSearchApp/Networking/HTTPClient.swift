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
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
