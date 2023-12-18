//
//  AlwaysDraggingTableView.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 18/12/2023.
//

import UIKit

final class AlwaysDraggingTableView: UITableView {
    override var isDragging: Bool {
        true
    }
    
    func simulateScrollUp() {
        setContentOffset(.init(x: 0, y: 0), animated: false)
    }
    
    func simulateScrollDown() {
        setContentOffset(.init(x: 0, y: 1), animated: false)
    }
}
