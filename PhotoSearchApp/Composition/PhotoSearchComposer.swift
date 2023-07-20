//
//  PhotoSearchComposer.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 19/07/2023.
//

import Combine
import Foundation

typealias LoadPhotosPublisher = AnyPublisher<[Photo], Error>
typealias LoadImagePublisher = AnyPublisher<Data, Error>

enum PhotoSearchComposer {
    static func composeWith(loadPhotosPublisher: @escaping (String) -> LoadPhotosPublisher,
                            loadImagePublisher: @escaping (Photo) -> LoadImagePublisher,
                            showError: @escaping (String, String) -> Void) -> PhotoSearchViewController {
        let loadPhotosPublisherAdapter = LoadPhotosPublisherAdapter(loadPhotosPublisher: loadPhotosPublisher)
        let viewController = PhotoSearchViewController(loadPhotos: loadPhotosPublisherAdapter.loadPhotos,
                                                       showError: showError)
        let photosViewAdapter = PhotosViewAdapter(view: viewController,
                                                  loadImagePublisher: loadImagePublisher)
        let presenter = PhotosPresenter(photosView: photosViewAdapter,
                                        loadingView: WeakRefProxy(viewController),
                                        errorView: WeakRefProxy(viewController))
        loadPhotosPublisherAdapter.presenter = presenter
        return viewController
    }
}

final class PhotosViewAdapter: PhotosView {
    private weak var viewController: PhotoSearchViewController?
    private let loadImagePublisher: (Photo) -> LoadImagePublisher
    
    init(view: PhotoSearchViewController,
         loadImagePublisher: @escaping (Photo) -> LoadImagePublisher) {
        self.viewController = view
        self.loadImagePublisher = loadImagePublisher
    }
    
    func display(_ viewModel: PhotosViewModel) {
        viewController?.display(viewModel.photos.map { photo in
            PhotoCellController(photo: photo, loadImagePublisher: loadImagePublisher)
        })
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
