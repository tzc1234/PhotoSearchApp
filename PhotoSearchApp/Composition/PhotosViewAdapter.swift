//
//  PhotosViewAdapter.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 20/07/2023.
//

import Combine
import Foundation

final class PhotosViewAdapter: PhotosView {
    private weak var viewController: PhotoSearchViewController?
    private let loadImagePublisher: (Photo) -> AnyPublisher<Data, Error>
    
    init(view: PhotoSearchViewController, loadImagePublisher: @escaping (Photo) -> AnyPublisher<Data, Error>) {
        self.viewController = view
        self.loadImagePublisher = loadImagePublisher
    }
    
    func display(_ viewModel: Paginated<Photo>) {
        guard let viewController else { return }
        
        let photoCells = viewModel.items.map { photo in
            CellController(PhotoCellComposer.composeWith(
                photoTitle: photo.title,
                loadImagePublisher: { [loadImagePublisher] in
                    loadImagePublisher(photo)
                }))
        }
        
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            viewController.display(photoCells)
            return
        }
        
        let loadMoreAdapter = LoadPhotosPublisherAdapter(publisher: loadMorePublisher)
        let searchTerm = viewController.searchTerm
        let loadMoreController = LoadMoreCellController(loadMore: { loadMoreAdapter.load(searchTerm) })
        loadMoreAdapter.presenter = PhotosPresenter(
            photosView: PhotosViewAdapter(view: viewController, loadImagePublisher: loadImagePublisher),
            loadingView: WeakRefProxy(loadMoreController),
            errorView: WeakRefProxy(viewController))
        
        viewController.display(photoCells, [CellController(loadMoreController)])
    }
}
