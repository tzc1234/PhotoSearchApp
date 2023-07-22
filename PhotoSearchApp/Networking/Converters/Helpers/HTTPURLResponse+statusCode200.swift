//
//  HTTPURLResponse+statusCode200.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 22/07/2023.
//

import Foundation

extension HTTPURLResponse {
    var isOK: Bool {
        statusCode == 200
    }
}
