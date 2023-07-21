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
    
    struct UnexpectedValueRepresentation: Error {}
    
    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
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
        XCTAssertNotNil(errorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(errorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(errorFor(data: anyData(), response: nonHTTPResponse(), error: nil))
        XCTAssertNotNil(errorFor(data: anyData(), response: anyHTTPResponse(), error: anyNSError()))
        XCTAssertNotNil(errorFor(data: anyData(), response: nonHTTPResponse(), error: anyNSError()))
        XCTAssertNotNil(errorFor(data: nil, response: nonHTTPResponse(), error: nil))
        XCTAssertNotNil(errorFor(data: nil, response: nonHTTPResponse(), error: anyNSError()))
        XCTAssertNotNil(errorFor(data: nil, response: anyHTTPResponse(), error: anyNSError()))
        XCTAssertNotNil(errorFor(data: nil, response: nil, error: anyNSError()))
    }
    
    func test_getFromURL_succeedsOnHTTPResponseWithData() {
        let data = anyData()
        let response = anyHTTPResponse()
        let received = valueFor(data: anyData(), response: anyHTTPResponse(), error: nil)
        
        XCTAssertEqual(received?.data, data)
        XCTAssertEqual(received?.response.url, response.url)
        XCTAssertEqual(received?.response.statusCode, response.statusCode)
    }
    
    func test_getFromURL_succeedsOnHTTPResponseWithNilData() {
        let response = anyHTTPResponse()
        let received = valueFor(data: nil, response: anyHTTPResponse(), error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(received?.data, emptyData)
        XCTAssertEqual(received?.response.url, response.url)
        XCTAssertEqual(received?.response.statusCode, response.statusCode)
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
    
    private func valueFor(data: Data?, response: URLResponse?, error: Error?,
                          file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let sut = makeSUT(file: file, line: line)
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        var receivedValue: (data: Data, response: HTTPURLResponse)?
        let exp = expectation(description: "Wait for request")
        sut.get(from: anyURL()) { result in
            switch result {
            case let .success((data, response)):
                receivedValue = (data, response)
            case .failure:
                XCTFail("Should not fail", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return receivedValue
    }
    
    private func errorFor(data: Data?, response: URLResponse?, error: Error?,
                          file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let sut = makeSUT(file: file, line: line)
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        var receivedError: Error?
        let exp = expectation(description: "Wait for request")
        sut.get(from: anyURL()) { result in
            switch result {
            case .success:
                XCTFail("Should not success", file: file, line: line)
            case let .failure(error):
                receivedError = error
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return receivedError
    }
    
    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
    
    private func anyData() -> Data {
        Data("any data".utf8)
    }
    
    private func nonHTTPResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
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
