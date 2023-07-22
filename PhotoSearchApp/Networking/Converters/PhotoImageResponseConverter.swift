//
//  PhotoImageResponseConverter.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 22/07/2023.
//

import Foundation

enum PhotoImageResponseConverter {
    enum Error: Swift.Error {
        case invalidResponse
    }
    
    static func convert(_ data: Data, response: HTTPURLResponse) throws -> Data {
        guard response.isOK else { throw Error.invalidResponse }
        
        return data
    }
}
