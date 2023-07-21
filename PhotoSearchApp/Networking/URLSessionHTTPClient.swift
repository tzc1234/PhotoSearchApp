//
//  URLSessionHTTPClient.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 21/07/2023.
//

import Foundation

final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        private let task: URLSessionTask
        
        init(_ task: URLSessionTask) {
            self.task = task
        }
        
        func cancel() {
            task.cancel()
        }
    }
    
    struct UnexpectedValueRepresentation: Error {}
    
    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(error))
            } else if let data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
        }
        task.resume()
        return URLSessionTaskWrapper(task)
    }
}
