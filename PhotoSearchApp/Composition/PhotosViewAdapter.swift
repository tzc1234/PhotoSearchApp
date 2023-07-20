//
//  PhotosViewAdapter.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 20/07/2023.
//

import Foundation

final class PhotosViewAdapter: PhotosView {
    private weak var viewController: PhotoSearchViewController?
    private let cellControllerCreator: (Photo) -> PhotoCellController
    
    init(view: PhotoSearchViewController,
         cellControllerCreator: @escaping (Photo) -> PhotoCellController) {
        self.viewController = view
        self.cellControllerCreator = cellControllerCreator
    }
    
    func display(_ viewModel: PhotosViewModel) {
        viewController?.display(viewModel.photos.map { photo in
            cellControllerCreator(photo)
        })
    }
}
