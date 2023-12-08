//
//  PhotoCellController.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 19/07/2023.
//

import UIKit

protocol PhotoCellControllerDelegate {
    func load()
    func cancel()
}

final class PhotoCellController: NSObject {
    private var cell: PhotoCell?
    
    private let delegate: PhotoCellControllerDelegate
    
    init(delegate: PhotoCellControllerDelegate) {
        self.delegate = delegate
    }
    
    static func configure(tableView: UITableView) {
        tableView.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.identifier)
    }
    
    private func loadImage(on cell: UITableViewCell) {
        guard let cell = cell as? PhotoCell else { return }
        
        self.cell = cell
        delegate.load()
    }
    
    private func cancelImageLoad() {
        releaseForReuse()
        delegate.cancel()
    }
    
    private func releaseForReuse() {
        cell = nil
    }
}

extension PhotoCellController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier) as! PhotoCell
        self.cell = cell
        delegate.load()
        cell.onReuse = { [weak self] in
            self?.cancelImageLoad()
        }
        return cell
    }
}

extension PhotoCellController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelImageLoad()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        loadImage(on: cell)
    }
}

extension PhotoCellController: PhotoImageView {
    func display(_ viewModel: PhotoImageViewModel<UIImage>) {
        cell?.titleLabel.text = viewModel.title
        cell?.blurView.isHidden = viewModel.title.isEmpty
        cell?.photoImageView.image = viewModel.image
    }
}

extension PhotoCellController: PhotoImageLoadingView {
    func display(_ viewModel: PhotoImageLoadingViewModel) {
        cell?.containerView.isShimmering = viewModel.isLoading
    }
}
