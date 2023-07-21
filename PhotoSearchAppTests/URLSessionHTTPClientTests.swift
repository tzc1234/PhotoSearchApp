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
    
    func get(from url: URL, completion: @escaping (Result<(Data, UIResponder), Error>) -> Void) {
        let task = session.dataTask(with: url) { data, response, error in
            completion(.failure(NSError(domain: "any error", code: 0)))
        }
        task.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        URLProtocolStub.reset()
    }
    
    func test_getFromURL_performsRequestForURL() {
        let url = URL(string: "https://request-url.com")!
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observe { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        sut.get(from: url) { _ in }
        wait(for: [exp], timeout: 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let sut = makeSUT()
        URLProtocolStub.stub(data: nil, response: nil, error: nil)
        
        let exp = expectation(description: "Wait for request")
        sut.get(from: anyURL()) { result in
            switch result {
            case .success:
                XCTFail("Should not success")
            case .failure:
                break
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
    
    private class URLProtocolStub: URLProtocol {
        struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
            let observer: ((URLRequest) -> Void)?
        }
        
        private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
        private static var _stub: Stub?
        private static var stub: Stub? {
            get { _stub }
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

}
