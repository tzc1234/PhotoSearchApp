//
//  PhotoCellController.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 19/07/2023.
//

import UIKit

final class PhotoCellController {
    private var cell: PhotoCell?
    private let loadImage: () -> Void
    private let cancelLoadImage: () -> Void
    
    init(loadImage: @escaping () -> Void, cancelLoadImage: @escaping () -> Void) {
        self.loadImage = loadImage
        self.cancelLoadImage = cancelLoadImage
    }
    
    func cell(in tableView: UITableView) -> PhotoCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier) as! PhotoCell
        self.cell = cell
        loadImage()
        cell.onReuse = { [weak self] in
            self?.cancelImageLoad()
        }
        return cell
    }
    
    func loadImage(on cell: UITableViewCell) {
        guard let cell = cell as? PhotoCell else { return }
        
        self.cell = cell
        loadImage()
    }
    
    func cancelImageLoad() {
        releaseForReuse()
        cancelLoadImage()
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
