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

final class PhotoCellController {
    private var cell: PhotoCell?
    
    private let delegate: PhotoCellControllerDelegate
    
    init(delegate: PhotoCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func cell(in tableView: UITableView) -> PhotoCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier) as! PhotoCell
        self.cell = cell
        delegate.load()
        cell.onReuse = { [weak self] in
            self?.cancelImageLoad()
        }
        return cell
    }
    
    func loadImage(on cell: UITableViewCell) {
        guard let cell = cell as? PhotoCell else { return }
        
        self.cell = cell
        delegate.load()
    }
    
    func cancelImageLoad() {
        releaseForReuse()
        delegate.cancel()
    }
    
    private func releaseForReuse() {
        cell = nil
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

extension PhotoCellController: Hashable {
    static func == (lhs: PhotoCellController, rhs: PhotoCellController) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
