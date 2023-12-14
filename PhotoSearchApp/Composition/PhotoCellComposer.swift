//
//  PhotoCellComposer.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 20/07/2023.
//

import Combine
import UIKit

enum PhotoCellComposer {
    typealias LoadImagePublisherAdapter = 
        LoadResourcePublisherAdapter<PhotoImagePresenter<WeakRefProxy<PhotoCellController>>, Void>
    
    static func composeWith(photoTitle: String,
                            loadImagePublisher: @escaping () -> AnyPublisher<Data, Error>) -> PhotoCellController {
        let adapter = LoadImagePublisherAdapter(publisher: loadImagePublisher)
        let cellController = PhotoCellController(delegate: adapter)
        adapter.presenter = PhotoImagePresenter(
            title: photoTitle,
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
