//
//  LoaderSpy.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 21/07/2023.
//

import Combine
import Foundation
@testable import PhotoSearchApp

class LoaderSpy {
    typealias LoadPhotosPublisher = PassthroughSubject<[Photo], Error>
    
    private var loadPhotosRequests = [(publisher: LoadPhotosPublisher, searchTerm: String)]()
    var loadPhotosCallCount: Int {
        loadPhotosRequests.count
    }
    var loggedSearchTerms: [String] {
        loadPhotosRequests.map(\.searchTerm)
    }
    
    private(set) var cancelLoadCallCount = 0
    
    func loadPhotosPublisher(searchTerm: String) -> AnyPublisher<[Photo], Error> {
        let publisher = LoadPhotosPublisher()
        loadPhotosRequests.append((publisher, searchTerm))
        return publisher.handleEvents(receiveCancel: { [weak self] in
            self?.cancelLoadCallCount += 1
        }).eraseToAnyPublisher()
    }
    
    func completePhotosLoad(with photos: [Photo], at index: Int) {
        guard index < loadPhotosRequests.count else { return }
        
        loadPhotosRequests[index].publisher.send(photos)
        loadPhotosRequests[index].publisher.send(completion: .finished)
    }
    
    func completePhotosLoad(with error: Error, at index: Int) {
        guard index < loadPhotosRequests.count else { return }
        loadPhotosRequests[index].publisher.send(completion: .failure(error))
    }
    
    // MARK: - Image data loader
    typealias LoadImagePublisher = PassthroughSubject<Data, Error>
    
    private var loadImageRequests = [(publisher: LoadImagePublisher, photo: Photo)]()
    var loggedPhotosForLoadImage: [Photo] {
        loadImageRequests.map(\.photo)
    }
    
    private(set) var cancelLoadImageCallCount = 0
    
    func loadImagePublisher(photo: Photo) -> AnyPublisher<Data, Error> {
        let publisher = LoadImagePublisher()
        loadImageRequests.append((publisher, photo))
        return publisher.handleEvents(receiveCancel: { [weak self] in
            self?.cancelLoadImageCallCount += 1
        }).eraseToAnyPublisher()
    }
    
    func completeImageLoad(with data: Data, at index: Int) {
        guard index < loadImageRequests.count else { return }
        
        loadImageRequests[index].publisher.send(data)
        loadImageRequests[index].publisher.send(completion: .finished)
    }
    
    func completeImageLoad(with error: Error, at index: Int) {
        guard index < loadImageRequests.count else { return }
        loadImageRequests[index].publisher.send(completion: .failure(error))
    }
}
