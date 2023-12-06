//
//  WeakRefProxy.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 20/07/2023.
//

import Foundation

final class WeakRefProxy<T: AnyObject> {
    private(set) weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefProxy: PhotosLoadingView where T: PhotosLoadingView {
    func display(_ viewModel: PhotosLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefProxy: PhotosErrorView where T: PhotosErrorView {
    func display(_ viewModel: PhotosErrorViewModel) {
        object?.display(viewModel)
    }
}
