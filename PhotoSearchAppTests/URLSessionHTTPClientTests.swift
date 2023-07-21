//
//  URLSessionHTTPClientTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 21/07/2023.
//

import XCTest
@testable import PhotoSearchApp

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
        
        _ = sut.get(from: url) { _ in }
        wait(for: [exp], timeout: 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        XCTAssertNotNil(errorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(errorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(errorFor((data: anyData(), response: nonHTTPResponse(), error: nil)))
        XCTAssertNotNil(errorFor((data: anyData(), response: anyHTTPResponse(), error: anyNSError())))
        XCTAssertNotNil(errorFor((data: anyData(), response: nonHTTPResponse(), error: anyNSError())))
        XCTAssertNotNil(errorFor((data: nil, response: nonHTTPResponse(), error: nil)))
        XCTAssertNotNil(errorFor((data: nil, response: nonHTTPResponse(), error: anyNSError())))
        XCTAssertNotNil(errorFor((data: nil, response: anyHTTPResponse(), error: anyNSError())))
        XCTAssertNotNil(errorFor((data: nil, response: nil, error: anyNSError())))
    }
    
    func test_getFromURL_succeedsOnHTTPResponseWithData() {
        let data = anyData()
        let response = anyHTTPResponse()
        let received = valueFor((data: anyData(), response: anyHTTPResponse(), error: nil))
        
        XCTAssertEqual(received?.data, data)
        XCTAssertEqual(received?.response.url, response.url)
        XCTAssertEqual(received?.response.statusCode, response.statusCode)
    }
    
    func test_getFromURL_succeedsOnHTTPResponseWithNilData() {
        let response = anyHTTPResponse()
        let received = valueFor((data: nil, response: anyHTTPResponse(), error: nil))
        
        let emptyData = Data()
        XCTAssertEqual(received?.data, emptyData)
        XCTAssertEqual(received?.response.url, response.url)
        XCTAssertEqual(received?.response.statusCode, response.statusCode)
    }
    
    func test_cancelGetFromURLTask_cancelsForRequest() {
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observe { _ in exp.fulfill() }
        
        let receivedError = errorFor(taskHandler: { $0.cancel() }) as? NSError
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
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
    
    private func valueFor(_ value: (data: Data?, response: URLResponse?, error: Error?)? = nil,
                          file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        var receivedValue: (data: Data, response: HTTPURLResponse)?
        let result = resultFor(value, file: file, line: line)
        switch result {
        case let .success((data, response)):
            receivedValue = (data, response)
        case .failure:
            XCTFail("Should not fail", file: file, line: line)
        }
        return receivedValue
    }
    
    private func errorFor(_ value: (data: Data?, response: URLResponse?, error: Error?)? = nil,
                          taskHandler: @escaping (HTTPClientTask) -> Void = { _ in },
                          file: StaticString = #filePath, line: UInt = #line) -> Error? {
        var receivedError: Error?
        let result = resultFor(value, taskHandler: taskHandler, file: file, line: line)
        switch result {
        case .success:
            XCTFail("Should not succeed", file: file, line: line)
        case let .failure(error):
            receivedError = error
        }
        return receivedError
    }
    
    private func resultFor(_ value: (data: Data?, response: URLResponse?, error: Error?)? = nil,
                           taskHandler: @escaping (HTTPClientTask) -> Void = { _ in },
                           file: StaticString = #filePath, line: UInt = #line) -> Result<(Data, HTTPURLResponse), Error> {
        let sut = makeSUT(file: file, line: line)
        value.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        
        var receivedResult: Result<(Data, HTTPURLResponse), Error>?
        let exp = expectation(description: "Wait for request")
        taskHandler(sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1)
        return receivedResult!
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
}
