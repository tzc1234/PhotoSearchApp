//
//  UIRefreshControl+TestHelpers.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 18/07/2023.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
