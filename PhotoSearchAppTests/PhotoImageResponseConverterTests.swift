//
//  PhotoImageResponseConverterTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 22/07/2023.
//

import XCTest
@testable import PhotoSearchApp

enum PhotoImageResponseConverter {
    enum Error: Swift.Error {
        case invalidResponse
    }
    
    static func convert(_ data: Data, response: HTTPURLResponse) throws -> Data {
        guard response.isOK else { throw Error.invalidResponse }
        
        return data
    }
}

final class PhotoImageResponseConverterTests: XCTestCase {
    func test_convert_deliversErrorOnNon200Response() throws {
        let samples = [100, 199, 201, 300, 400, 500]
        
        try samples.forEach { statusCode in
            let response = HTTPURLResponse(statusCode: statusCode)
            XCTAssertThrowsError(try PhotoImageResponseConverter.convert(anyData(), response: response), "Expect an error at statusCode: \(statusCode)")
        }
    }
    
    func test_convert_deliversDataOn200Response() throws {
        let expectedData = anyData()
        
        let data = try PhotoImageResponseConverter.convert(expectedData, response: ok200Response())
        
        XCTAssertEqual(data, expectedData)
    }
}
