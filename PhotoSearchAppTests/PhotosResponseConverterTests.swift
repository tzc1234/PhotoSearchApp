//
//  PhotosResponseConverterTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 22/07/2023.
//

import XCTest
@testable import PhotoSearchApp

enum PhotosResponseConverter {
    enum Error: Swift.Error {
        case invalidData
    }
    
    static func convert(from data: Data, response: HTTPURLResponse) throws -> [Photo] {
        throw Error.invalidData
    }
}

final class PhotosResponseConverterTests: XCTestCase {
    func test_convert_deliversErrorOnNon200Response() throws {
        let data = anyData()
        let samples = [100, 199, 201, 300, 400, 500]
        
        try samples.forEach { statusCode in
            let response = HTTPURLResponse(statusCode: statusCode)
            XCTAssertThrowsError(try PhotosResponseConverter.convert(from: data, response: response), "Expect an error at statusCode: \(statusCode)")
        }
    }
    
    func test_convert_deliversErrorOn200ResponseWithInvalidData() {
        let invalidData = Data("invalid data".utf8)
        
        XCTAssertThrowsError(try PhotosResponseConverter.convert(from: invalidData, response: okResponse()))
    }
    
    // MARK: - Helpers
    
    private func okResponse() -> HTTPURLResponse {
        HTTPURLResponse(statusCode: 200)
    }
    
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
