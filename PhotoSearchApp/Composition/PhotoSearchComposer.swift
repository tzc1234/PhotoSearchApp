//
//  PhotoSearchComposer.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 19/07/2023.
//

import Combine
import Foundation

enum PhotoSearchComposer {
    typealias LoadPhotosPublisherAdapter = LoadResourcePublisherAdapter<PhotosPresenter, String, [Photo]>
    
    static func composeWith(loadPhotosPublisher: @escaping (String) -> AnyPublisher<[Photo], Error>,
                            loadImagePublisher: @escaping (Photo) -> AnyPublisher<Data, Error>,
                            showError: @escaping (ErrorMessage) -> Void) -> PhotoSearchViewController {
        let loadPhotosPublisherAdapter = LoadPhotosPublisherAdapter(publisher: loadPhotosPublisher)
        let viewController = PhotoSearchViewController(
            loadPhotos: loadPhotosPublisherAdapter.load,
            showError: showError)
        
        let photosViewAdapter = PhotosViewAdapter(
            view: viewController,
            cellControllerCreator: { photo in
                PhotoCellComposer.composeWith(
                    photoTitle: photo.title,
                    loadImagePublisher: { loadImagePublisher(photo) }
                )
            })
        
        loadPhotosPublisherAdapter.presenter = PhotosPresenter(
            photosView: photosViewAdapter,
            loadingView: WeakRefProxy(viewController),
            errorView: WeakRefProxy(viewController))
        
        return viewController
    }
}

extension WeakRefProxy: PhotosLoadingView where T: PhotosLoadingView {
    func display(_ viewModel: PhotosLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefProxy: PhotosErrorView where T: PhotosErrorView {
    func display(_ viewModel: PhotosErrorViewModel) {
        object?.display(viewModel)
    }
}
