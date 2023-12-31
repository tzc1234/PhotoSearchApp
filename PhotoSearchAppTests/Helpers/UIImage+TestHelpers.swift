//
//  UIImage+TestHelpers.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 19/07/2023.
//

import UIKit

extension UIImage {
    static func makeData(withColor color: UIColor) -> Data {
        make(withColor: color).pngData()!
    }
    
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}
