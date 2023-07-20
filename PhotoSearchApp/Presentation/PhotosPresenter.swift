//
//  PhotosPresenter.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 20/07/2023.
//

import Foundation

protocol PhotosErrorView: AnyObject {
    func display(_ viewModel: PhotosErrorViewModel)
}

protocol PhotosView {
    func display(_ viewModel: PhotosViewModel)
}

protocol PhotosLoadingView: AnyObject {
    func display(_ viewModel: PhotosLoadingViewModel)
}

final class PhotosPresenter {
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
        errorView.display(PhotosErrorViewModel(title: nil, message: nil))
    }
    
    func didFinishLoading(with photos: [Photo]) {
        loadingView.display(PhotosLoadingViewModel(isLoading: false))
        photosView.display(PhotosViewModel(photos: photos))
    }
    
    func didFinishLoading(with error: Error) {
        loadingView.display(PhotosLoadingViewModel(isLoading: false))
        errorView.display(PhotosErrorViewModel(title: Self.errorTitle, message: Self.errorMessage))
    }
    
    static var errorTitle: String { "Oops!" }
    static var errorMessage: String { "Network error occurred, please try again." }
}
