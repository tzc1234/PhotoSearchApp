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

final class PhotoImagePresenter<View: PhotoImageView, Image>: ResourcePresenter where View.Image == Image {
    typealias Resource = Data
    
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
    
    func didFinishLoading(with resource: Resource) {
        loadingView.display(PhotoImageLoadingViewModel(isLoading: false))
        view.display(PhotoImageViewModel(title: title, image: imageConverter(resource)))
    }
    
    func didFinishLoadingWithError() {
        loadingView.display(PhotoImageLoadingViewModel(isLoading: false))
    }
}
