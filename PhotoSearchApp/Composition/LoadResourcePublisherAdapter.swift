//
//  LoadResourcePublisherAdapter.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 21/07/2023.
//

import Combine
import Foundation

final class LoadResourcePublisherAdapter<Presenter: ResourcePresenter, Input, Resource> where Presenter.Resource == Resource {
    private var cancellable: Cancellable?
    var presenter: Presenter?
    
    private let publisher: (Input) -> AnyPublisher<Resource, Error>
    
    init(publisher: @escaping (Input) -> AnyPublisher<Resource, Error>) {
        self.publisher = publisher
    }
    
    func load(_ input: Input) {
        presenter?.didStartLoading()
        
        cancellable = publisher(input)
            .receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.presenter?.didFinishLoading(with: error)
                }
            }, receiveValue: { [weak self] resource in
                self?.presenter?.didFinishLoading(with: resource)
            })
    }
}

extension LoadResourcePublisherAdapter: ImageLoader where Input == Void {
    func load() {
        load(())
    }
    
    func cancel() {
        cancellable?.cancel()
        cancellable = nil
    }
}
