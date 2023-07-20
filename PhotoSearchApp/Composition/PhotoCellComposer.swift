//
//  PhotoCellComposer.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 20/07/2023.
//

import UIKit

enum PhotoCellComposer {
    static func composeWith(photoTitle: String,
                            loadImagePublisher: @escaping () -> LoadImagePublisher) -> PhotoCellController {
        let adapter = LoadImagePublisherAdapter(loadImagePublisher: loadImagePublisher)
        let cellController = PhotoCellController(imageLoader: adapter)
        adapter.presenter = PhotoImagePresenter(title: photoTitle,
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
