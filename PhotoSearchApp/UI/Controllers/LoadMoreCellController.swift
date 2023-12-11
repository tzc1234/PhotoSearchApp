//
//  LoadMoreCellController.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 06/12/2023.
//

import UIKit

final class LoadMoreCellController: NSObject {
    private let cell = UITableViewCell()
    private var isLoading = false
    private var offsetObserver: NSKeyValueObservation?
    
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
        cell.selectionStyle = .none
        return cell
    }
}

extension LoadMoreCellController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        loadMore()
        
        offsetObserver = tableView.observe(\.contentOffset, options: [.old, .new]) { [weak self] tableView, value in
            guard tableView.isDragging, let old = value.oldValue?.y, let new = value.newValue?.y, new > old else {
                return
            }
            
            self?.loadMore()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        offsetObserver = nil
    }
}

extension LoadMoreCellController: PhotosLoadingView {
    func display(_ viewModel: PhotosLoadingViewModel) {
        isLoading = viewModel.isLoading
    }
}
