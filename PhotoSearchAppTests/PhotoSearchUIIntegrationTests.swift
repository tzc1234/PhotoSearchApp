//
//  PhotoSearchUIIntegrationTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 18/07/2023.
//

import Combine
import XCTest
@testable import PhotoSearchApp

class PhotoSearchViewController: UITableViewController {
    private var loadPhotosCancellable: Cancellable?
    private let loader: LoaderSpy
    
    init(loader: LoaderSpy) {
        self.loader = loader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
        loadPhotos()
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadPhotos), for: .valueChanged)
    }
    
    @objc private func loadPhotos() {
        loadPhotosCancellable?.cancel()
        loadPhotosCancellable = loader.loadPublisher()
            .sink(receiveCompletion: { completion in
                
            }, receiveValue: { _ in
                
            })
    }
}

class LoaderSpy {
    private(set) var cancelLoadCallCount = 0
    private(set) var loadRequests = [PassthroughSubject<Void, Error>]()
    var loadCallCount: Int {
        loadRequests.count
    }
    
    func loadPublisher() -> AnyPublisher<Void, Error> {
        let publisher = PassthroughSubject<Void, Error>()
        loadRequests.append(publisher)
        return publisher.handleEvents(receiveCancel: { [weak self] in
            self?.cancelLoadCallCount += 1
        }).eraseToAnyPublisher()
    }
    
    func complete(with error: Error, at index: Int) {
        guard index < loadRequests.count else { return }
        loadRequests[index].send(completion: .failure(error))
    }
}

final class PhotoSearchUIIntegrationTests: XCTestCase {

    func test_init_doesNotNotifyLoader() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }

    func test_photosLoading_requestsPhotosFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expect zero photos loads before the view rendering completed")
        XCTAssertEqual(loader.cancelLoadCallCount, 0, "Expect zero cancel photos loads before a cancel the view rendering completed")
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1, "Expect a photos load after the view rendering completed")
        
        sut.simulateUserInitiatedReload()

        XCTAssertEqual(loader.loadCallCount, 2, "Expect two photos loads after user initiated a photos reload")
        XCTAssertEqual(loader.cancelLoadCallCount, 1, "Expect one cancel load after an uncompleted request")
        
        loader.complete(with: NSError(domain: "any error", code: 0), at: 1)
        sut.simulateUserInitiatedReload()
        
        XCTAssertEqual(loader.loadCallCount, 3, "Expect three photos loads after user initiated second photos reload")
        XCTAssertEqual(loader.cancelLoadCallCount, 1, "Expect no changes because no more request uncompleted")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: PhotoSearchViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = PhotoSearchViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
}

extension PhotoSearchViewController {
    func simulateUserInitiatedReload() {
        refreshControl?.simulate(event: .valueChanged)
    }
}
