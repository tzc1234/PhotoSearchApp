//
//  HTTPClientStub.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 04/12/2023.
//

import Foundation
@testable import PhotoSearchApp

final class HTTPClientStub: HTTPClient {
    private let stub: (URL) -> HTTPClient.Result
    
    init(stub: @escaping (URL) -> HTTPClient.Result) {
        self.stub = stub
    }
    
    private struct Task: HTTPClientTask {
        func cancel() {}
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        completion(stub(url))
        return Task()
    }
    
    static var offline: Self {
        .init(stub: { _ in .failure(anyNSError()) })
    }
    
    static func online(_ response: @escaping (URL) -> (Data, HTTPURLResponse)) -> Self {
        .init(stub: { .success(response($0)) })
    }
}
