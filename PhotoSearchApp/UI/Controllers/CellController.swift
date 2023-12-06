//
//  CellController.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 05/12/2023.
//

import UIKit

struct CellController: Hashable {
    private let uuid = UUID()
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate
    
    init(_ dataSource: UITableViewDataSource & UITableViewDelegate) {
        self.dataSource = dataSource
        self.delegate = dataSource
    }
    
    static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
