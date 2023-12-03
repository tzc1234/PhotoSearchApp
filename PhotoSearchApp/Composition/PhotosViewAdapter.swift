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
    
    func display(_ viewModel: PhotosViewModel) {
        viewController?.display(viewModel.photos.map { photo in
            PhotoCellComposer.composeWith(
                photoTitle: photo.title,
                loadImagePublisher: { [loadImagePublisher] in
                    loadImagePublisher(photo)
                })
        })
    }
}
