//
//  PhotoCellController.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 19/07/2023.
//

import UIKit

protocol ImageLoader {
    func load()
    func cancel()
}

final class PhotoCellController {
    private var cell: PhotoCell?
    private let imageLoader: ImageLoader
    
    init(imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
    }
    
    func cell(in tableView: UITableView) -> PhotoCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier) as! PhotoCell
        self.cell = cell
        imageLoader.load()
        cell.onReuse = { [weak self] in
            self?.cancelImageLoad()
        }
        return cell
    }
    
    func loadImage(on cell: UITableViewCell) {
        guard let cell = cell as? PhotoCell else { return }
        
        self.cell = cell
        imageLoader.load()
    }
    
    func cancelImageLoad() {
        releaseForReuse()
        imageLoader.cancel()
    }
    
    private func releaseForReuse() {
        cell = nil
    }
}

extension PhotoCellController: Hashable {
    static func == (lhs: PhotoCellController, rhs: PhotoCellController) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension PhotoCellController: PhotoImageView {
    func display(_ viewModel: PhotoImageViewModel<UIImage>) {
        cell?.titleLabel.text = viewModel.title
        cell?.photoImageView.image = viewModel.image
    }
}

extension PhotoCellController: PhotoImageLoadingView {
    func display(_ viewModel: PhotoImageLoadingViewModel) {
        cell?.containerView.isShimmering = viewModel.isLoading
    }
}
