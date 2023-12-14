//
//  PhotosPresenter.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 20/07/2023.
//

import Foundation

protocol PhotosErrorView {
    func display(_ viewModel: PhotosErrorViewModel)
}

protocol PhotosView {
    func display(_ viewModel: Paginated<Photo>)
}

protocol PhotosLoadingView {
    func display(_ viewModel: PhotosLoadingViewModel)
}

final class PhotosPresenter: ResourcePresenter {
    static var errorTitle: String { "Oops!" }
    static var errorMessage: String { "Network error occurred, please try again." }
    
    private let photosView: PhotosView
    private let loadingView: PhotosLoadingView
    private let errorView: PhotosErrorView
    
    init(photosView: PhotosView, loadingView: PhotosLoadingView, errorView: PhotosErrorView) {
        self.photosView = photosView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func didStartLoading() {
        loadingView.display(PhotosLoadingViewModel(isLoading: true))
        errorView.display(PhotosErrorViewModel(message: nil))
    }
    
    func didFinishLoading(with resource: Paginated<Photo>) {
        loadingView.display(PhotosLoadingViewModel(isLoading: false))
        photosView.display(resource)
    }
    
    func didFinishLoadingWithError() {
        loadingView.display(PhotosLoadingViewModel(isLoading: false))
        errorView.display(PhotosErrorViewModel(message: ErrorMessage(
            title: Self.errorTitle, 
            message: Self.errorMessage
        )))
    }
}
