//
//  LoadImagePublisherAdapter.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 20/07/2023.
//

import Combine
import UIKit

final class LoadImagePublisherAdapter {
    private var cancellable: Cancellable?
    private let loadImagePublisher: (Photo) -> LoadImagePublisher
    var presenter: PhotoImagePresenter<WeakRefProxy<PhotoCellController>, UIImage>?
    
    init(loadImagePublisher: @escaping (Photo) -> LoadImagePublisher) {
        self.loadImagePublisher = loadImagePublisher
    }
    
    func loadImage(by photo: Photo) {
        presenter?.didStartLoading()
        
        cancellable = loadImagePublisher(photo)
            .receive(on: DispatchQueue.immediateWhenOnMainQueueScheluder)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.presenter?.didFinishLoading(with: error)
                }
            }, receiveValue: { [weak self] data in
                self?.presenter?.didFinishLoading(with: data)
            })
    }
    
    func cancelLoadImage() {
        cancellable?.cancel()
        cancellable = nil
    }
}
