//
//  LoadResourcePublisherAdapter.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 21/07/2023.
//

import Combine
import Foundation

final class LoadResourcePublisherAdapter<Presenter: ResourcePresenter, Input> {
    private var cancellable: Cancellable?
    private var isLoading = false
    var presenter: Presenter?
    
    private let publisher: (Input) -> AnyPublisher<Presenter.Resource, Error>
    
    init(publisher: @escaping (Input) -> AnyPublisher<Presenter.Resource, Error>) {
        self.publisher = publisher
    }
    
    func load(_ input: Input) {
        guard !isLoading else { return }
        
        isLoading = true
        presenter?.didStartLoading()
        
        cancellable = publisher(input)
            .receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.presenter?.didFinishLoadingWithError()
                }
                
                self?.isLoading = false
            }, receiveValue: { [weak self] resource in
                self?.presenter?.didFinishLoading(with: resource)
            })
    }
}

extension LoadResourcePublisherAdapter: PhotoCellControllerDelegate where Input == Void {
    func load() {
        load(())
    }
    
    func cancel() {
        cancellable?.cancel()
        cancellable = nil
        isLoading = false
    }
}
