//
//  HTTPURLResponse+TestHelpers.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 03/12/2023.
//

import Foundation

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
