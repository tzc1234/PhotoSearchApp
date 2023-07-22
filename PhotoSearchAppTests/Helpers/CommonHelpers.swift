//
//  CommonHelpers.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 21/07/2023.
//

import Foundation
@testable import PhotoSearchApp

func anyNSError() -> Error {
    NSError(domain: "any error", code: 0)
}

func anyData() -> Data {
    Data("any data".utf8)
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func makePhoto(id: String = "any id", title: String = "any title",
               server: String = "any-server", secret: String = "any-secret") -> Photo {
    .init(id: id, title: title, server: server, secret: secret)
}

func ok200Response() -> HTTPURLResponse {
    HTTPURLResponse(statusCode: 200)
}
