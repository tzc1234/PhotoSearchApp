//
//  URLSessionHTTPClientTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 21/07/2023.
//

import XCTest
@testable import PhotoSearchApp

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        let task = session.dataTask(with: url)
        task.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_get_performsRequestForURL() {
        let url = URL(string: "https://request-url.com")!
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observe { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        sut.get(from: url)
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private class URLProtocolStub: URLProtocol {
        private static var observer: ((URLRequest) -> Void)?
        
        static func observe(_ observer: @escaping (URLRequest) -> Void) {
            self.observer = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            client?.urlProtocolDidFinishLoading(self)

            Self.observer?(request)
        }
        
        override func stopLoading() {}
    }

}
