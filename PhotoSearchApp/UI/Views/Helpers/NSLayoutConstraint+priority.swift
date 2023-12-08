//
//  NSLayoutConstraint+priority.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 08/12/2023.
//

import UIKit

extension NSLayoutConstraint {
    func prioritised(_ priority: Float) -> NSLayoutConstraint {
        self.priority = .init(priority)
        return self
    }
}
