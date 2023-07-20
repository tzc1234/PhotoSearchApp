//
//  PhotoImagePresenter.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 20/07/2023.
//

import Foundation

protocol PhotoImageView {
    associatedtype Image
    func display(_ viewModel: PhotoImageViewModel<Image>)
}

protocol PhotoImageLoadingView {
    func display(_ viewModel: PhotoImageLoadingViewModel)
}

final class PhotoImagePresenter<View: PhotoImageView, Image> where View.Image == Image {
    private let title: String
    private let view: View
    private let loadingView: PhotoImageLoadingView
    private let imageConverter: (Data) -> Image?
    
    init(title: String, view: View, loadingView: PhotoImageLoadingView, imageConverter: @escaping (Data) -> Image?) {
        self.title = title
        self.view = view
        self.loadingView = loadingView
        self.imageConverter = imageConverter
    }
    
    func didStartLoading() {
        loadingView.display(PhotoImageLoadingViewModel(isLoading: true))
        view.display(PhotoImageViewModel(title: title, image: nil))
    }
    
    func didFinishLoading(with data: Data) {
        loadingView.display(PhotoImageLoadingViewModel(isLoading: false))
        view.display(PhotoImageViewModel(title: title, image: imageConverter(data)))
    }
    
    func didFinishLoading(with error: Error) {
        loadingView.display(PhotoImageLoadingViewModel(isLoading: false))
    }
}
