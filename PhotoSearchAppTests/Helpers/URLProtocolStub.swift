//
//  URLProtocolStub.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 21/07/2023.
//

import Foundation

class URLProtocolStub: URLProtocol {
    struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let observer: ((URLRequest) -> Void)?
    }
    
    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
    private static var _stub: Stub?
    private static var stub: Stub? {
        get { queue.sync { _stub } }
        set { queue.sync { _stub = newValue } }
    }
    
    static func reset() {
        self.stub = nil
    }
    
    static func observe(_ observer: @escaping (URLRequest) -> Void) {
        self.stub = Stub(data: nil, response: nil, error: nil, observer: observer)
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        self.stub = Stub(data: data, response: response, error: error, observer: nil)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        let stub = Self.stub
        
        if let data = stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
        
        stub?.observer?(request)
    }
    
    override func stopLoading() {}
}
