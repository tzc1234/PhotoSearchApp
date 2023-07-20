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
        let viewController = PhotoSearchViewController(loadPhotos: loadPhotosPublisherAdapter.loadPhotos, showError: showError)
        let photosViewAdapter = PhotosViewAdapter(viewController: viewController, loadImagePublisher: loadImagePublisher)
        let presenter = PhotosPresenter(photosView: photosViewAdapter, loadingView: viewController, errorView: viewController)
        loadPhotosPublisherAdapter.presenter = presenter
        return viewController
    }
}

final class LoadPhotosPublisherAdapter {
    private var loadPhotosCancellable: Cancellable?
    private let loadPhotosPublisher: (String) -> LoadPhotosPublisher
    var presenter: PhotosPresenter?
    
    init(loadPhotosPublisher: @escaping (String) -> LoadPhotosPublisher) {
        self.loadPhotosPublisher = loadPhotosPublisher
    }
    
    func loadPhotos(by searchTerm: String) {
        presenter?.didStartLoading()
        
        loadPhotosCancellable = loadPhotosPublisher(searchTerm)
            .receive(on: DispatchQueue.immediateWhenOnMainQueueScheluder)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.presenter?.didFinishLoading(with: error)
                }
            }, receiveValue: { [weak self] photos in
                self?.presenter?.didFinishLoading(with: photos)
            })
    }
}

final class PhotosViewAdapter: PhotosView {
    private weak var viewController: PhotoSearchViewController?
    private let loadImagePublisher: (Photo) -> LoadImagePublisher
    
    init(viewController: PhotoSearchViewController,
         loadImagePublisher: @escaping (Photo) -> LoadImagePublisher) {
        self.viewController = viewController
        self.loadImagePublisher = loadImagePublisher
    }
    
    func display(_ viewModel: PhotosViewModel) {
        viewController?.display(viewModel.photos.map { photo in
            PhotoCellController(photo: photo, loadImagePublisher: loadImagePublisher)
        })
    }
}
