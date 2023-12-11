//
//  LoadMoreCell+TestHelpers.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 11/12/2023.
//

import Foundation
@testable import PhotoSearchApp

extension LoadMoreCell {
    var isShowingLoadingIndicator: Bool {
        isLoading
    }
    
    var title: String? {
        titleLabel.text
    }
    
    var message: String? {
        messageLabel.text
    }
}
