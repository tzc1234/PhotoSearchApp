//
//  PhotoCell+TestHelpers.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 20/07/2023.
//

import UIKit
@testable import PhotoSearchApp

extension PhotoCell {
    var titleText: String? {
        titleLabel.text
    }
    
    var renderedImage: Data? {
        photoImageView.image?.pngData()
    }
    
    var isShowingLoadingIndicator: Bool {
        containerView.isShimmering
    }
}
