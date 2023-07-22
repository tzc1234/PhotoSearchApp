//
//  PhotoImageResponseConverterTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 22/07/2023.
//

import XCTest

enum PhotoImageResponseConverter {
    enum Error: Swift.Error {
        case invalidResponse
    }
    
    static func convert(from data: Data, response: HTTPURLResponse) throws -> Data {
        throw Error.invalidResponse
    }
}

final class PhotoImageResponseConverterTests: XCTestCase {
    func test_convert_deliversErrorOnNon200Response() throws {
        let samples = [100, 199, 201, 300, 400, 500]
        
        try samples.forEach { statusCode in
            let response = HTTPURLResponse(statusCode: statusCode)
            XCTAssertThrowsError(try PhotoImageResponseConverter.convert(from: anyData(), response: response), "Expect an error at statusCode: \(statusCode)")
        }
    }
}
