//
//  PhotoSearchComposer.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 19/07/2023.
//

import Combine
import Foundation

typealias LoadPhotosPublisher = AnyPublisher<[Photo], Error>

enum PhotoSearchComposer {
    static func composeWith(loadPhotosPublisher: @escaping (String) -> LoadPhotosPublisher,
                            loadImagePublisher: @escaping (Photo) -> PhotoCellController.LoadImagePublisher,
                            showError: @escaping (String, String) -> Void) -> PhotoSearchViewController {
        let adapter = LoadPhotosPublisherAdapter(loadPhotosPublisher: loadPhotosPublisher, loadImagePublisher: loadImagePublisher)
        let viewController = PhotoSearchViewController(loadPhotos: adapter.loadPhotos, showError: showError)
        adapter.viewController = viewController
        return viewController
    }
}

final class LoadPhotosPublisherAdapter {
    private var loadPhotosCancellable: Cancellable?
    private let loadPhotosPublisher: (String) -> LoadPhotosPublisher
    private let loadImagePublisher: (Photo) -> PhotoCellController.LoadImagePublisher
    weak var viewController: PhotoSearchViewController?
    
    init(loadPhotosPublisher: @escaping (String) -> LoadPhotosPublisher,
         loadImagePublisher: @escaping (Photo) -> PhotoCellController.LoadImagePublisher) {
        self.loadPhotosPublisher = loadPhotosPublisher
        self.loadImagePublisher = loadImagePublisher
    }
    
    func loadPhotos(by searchTerm: String) {
        viewController?.refreshControl?.beginRefreshing()
        
        loadPhotosCancellable = loadPhotosPublisher(searchTerm)
            .receive(on: DispatchQueue.immediateWhenOnMainQueueScheluder)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.viewController?.showErrorView()
                }
                
                self?.viewController?.refreshControl?.endRefreshing()
            }, receiveValue: { [weak self] photos in
                guard let self else { return }
                
                self.viewController?.display(photos.map { photo in
                    PhotoCellController(photo: photo, loadImagePublisher: self.loadImagePublisher)
                })
            })
    }
}
