//
//  LoadMoreCellController.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 06/12/2023.
//

import UIKit

final class LoadMoreCellController: NSObject {
    private let cell = UITableViewCell()
    
    private let loadMore: () -> Void
    
    init(loadMore: @escaping () -> Void) {
        self.loadMore = loadMore
    }
}

extension LoadMoreCellController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell
    }
}

extension LoadMoreCellController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        loadMore()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        48
    }
}
