//
//  PhotoCellComposer.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 20/07/2023.
//

import UIKit

enum PhotoCellComposer {
    static func composeWith(photo: Photo,
                            loadImagePublisher: @escaping (Photo) -> LoadImagePublisher) -> PhotoCellController {
        let adapter = LoadImagePublisherAdapter(loadImagePublisher: loadImagePublisher)
        let cellController = PhotoCellController(loadImage: { adapter.loadImage(by: photo) },
                                                 cancelLoadImage: adapter.cancelLoadImage)
        adapter.presenter = PhotoImagePresenter(title: photo.title,
                                                view: WeakRefProxy(cellController),
                                                loadingView: WeakRefProxy(cellController),
                                                imageConverter: UIImage.init)
        return cellController
    }
}

extension WeakRefProxy: PhotoImageView where T: PhotoImageView, T.Image == UIImage {
    func display(_ viewModel: PhotoImageViewModel<UIImage>) {
        object?.display(viewModel)
    }
}

extension WeakRefProxy: PhotoImageLoadingView where T: PhotoImageLoadingView {
    func display(_ viewModel: PhotoImageLoadingViewModel) {
        object?.display(viewModel)
    }
}
