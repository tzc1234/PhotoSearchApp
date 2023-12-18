//
//  RefreshControlSpy.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 18/12/2023.
//

import UIKit

final class RefreshControlSpy: UIRefreshControl {
    private var _isRefreshing = false
    
    override var isRefreshing: Bool {
        _isRefreshing
    }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}
