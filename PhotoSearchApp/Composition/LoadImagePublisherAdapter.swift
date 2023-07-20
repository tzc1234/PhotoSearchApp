//
//  LoadImagePublisherAdapter.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 20/07/2023.
//

import Combine
import UIKit

final class LoadImagePublisherAdapter: ImageLoader {
    private var cancellable: Cancellable?
    private let loadImagePublisher: () -> LoadImagePublisher
    var presenter: PhotoImagePresenter<WeakRefProxy<PhotoCellController>, UIImage>?
    
    init(loadImagePublisher: @escaping () -> LoadImagePublisher) {
        self.loadImagePublisher = loadImagePublisher
    }
    
    func load() {
        presenter?.didStartLoading()
        
        cancellable = loadImagePublisher()
            .receive(on: DispatchQueue.immediateWhenOnMainQueueScheluder)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.presenter?.didFinishLoading(with: error)
                }
            }, receiveValue: { [weak self] data in
                self?.presenter?.didFinishLoading(with: data)
            })
    }
    
    func cancel() {
        cancellable?.cancel()
        cancellable = nil
    }
}
