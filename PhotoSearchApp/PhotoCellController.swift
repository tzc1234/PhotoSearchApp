//
//  PhotoCellController.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 19/07/2023.
//

import Combine
import UIKit

final class PhotoCellController {
    typealias LoadImagePublisher = AnyPublisher<Data, Error>
    
    private var cell: PhotoCell?
    private var loadImageCancellable: Cancellable?
    
    private let photo: Photo
    private let loadImagePublisher: (Photo) -> LoadImagePublisher
    
    init(photo: Photo, loadImagePublisher: @escaping (Photo) -> LoadImagePublisher) {
        self.photo = photo
        self.loadImagePublisher = loadImagePublisher
    }
    
    func cell(in tableView: UITableView) -> PhotoCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier) as! PhotoCell
        self.cell = cell
        cell.titleLabel.text = photo.title
        loadImage(on: cell)
        cell.onReuse = { [weak self] in
            self?.cancelImageLoad()
        }
        return cell
    }
    
    func loadImage(on cell: UITableViewCell) {
        guard let cell = cell as? PhotoCell else { return }
        
        self.cell = cell
        cell.containerView.isShimmering = true
        loadImageCancellable = loadImagePublisher(photo)
            .receive(on: DispatchQueue.immediateWhenOnMainQueueScheluder)
            .sink(receiveCompletion: { [weak self] _ in
                self?.cell?.containerView.isShimmering = false
            }, receiveValue: { [weak self] data in
                self?.cell?.photoImageView.image = UIImage(data: data)
            })
    }
    
    func cancelImageLoad() {
        releaseForReuse()
        loadImageCancellable?.cancel()
        loadImageCancellable = nil
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
