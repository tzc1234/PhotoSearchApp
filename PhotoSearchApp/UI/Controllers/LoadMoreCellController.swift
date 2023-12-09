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
        reloadIfNeeded()
        
        offsetObserver = tableView.observe(\.contentOffset, options: .new, changeHandler: { [weak self] tableView, _ in
            guard tableView.isDragging else { return }
            
            self?.reloadIfNeeded()
        })
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        offsetObserver = nil
    }
    
    private func reloadIfNeeded() {
        guard !isLoading else { return }

        loadMore()
    }
}

extension LoadMoreCellController: PhotosLoadingView {
    func display(_ viewModel: PhotosLoadingViewModel) {
        isLoading = viewModel.isLoading
    }
}
