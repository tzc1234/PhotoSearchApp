//
//  PhotosErrorViewModel.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 20/07/2023.
//

import Foundation

struct PhotosErrorViewModel {
    let message: ErrorMessage?
}

struct ErrorMessage: Equatable {
    let title: String
    let message: String
}
