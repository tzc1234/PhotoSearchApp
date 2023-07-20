//
//  PhotosViewAdapter.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 20/07/2023.
//

import Foundation

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
            PhotoCellComposer.composeWith(photo: photo, loadImagePublisher: loadImagePublisher)
        })
    }
}
