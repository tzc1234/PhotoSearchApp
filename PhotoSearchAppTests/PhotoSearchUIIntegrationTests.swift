//
//  PhotoSearchUIIntegrationTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 18/07/2023.
//

import Combine
import XCTest
@testable import PhotoSearchApp

class PhotoSearchViewController: UITableViewController, UISearchBarDelegate {
    typealias LoadPhotosPublisher = AnyPublisher<Void, Error>
    
    private(set) lazy var searchBar = {
        let bar = UISearchBar()
        bar.delegate = self
        return bar
    }()
    
    private var searchTerm = ""
    private var loadPhotosCancellable: Cancellable?
    private let loadPhotosPublisher: (String) -> LoadPhotosPublisher
    
    init(loadPhotosPublisher: @escaping (String) -> LoadPhotosPublisher) {
        self.loadPhotosPublisher = loadPhotosPublisher
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
        loadPhotosCancellable = loadPhotosPublisher(searchTerm)
            .sink(receiveCompletion: { completion in
                
            }, receiveValue: { _ in
                
            })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTerm = searchText
        loadPhotos()
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
        
        loader.complete(with: anyNSError(), at: 1)
        sut.simulateUserInitiatedReload()
        
        XCTAssertEqual(loader.loadCallCount, 3, "Expect three photos loads after user initiated second photos reload")
        XCTAssertEqual(loader.cancelLoadCallCount, 1, "Expect no changes because no more request uncompleted")
    }
    
    func test_photosSearching_requestsPhotosWithSearchTermFromLoader() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loggedSearchTerms, [""], "Expect one search term logged after view rendered")
        
        let searchTerm0 = "term 0"
        sut.simulateSearchPhotos(by: searchTerm0)
        
        XCTAssertEqual(loader.loadCallCount, 2, "Expect two photos loads after search photos")
        XCTAssertEqual(loader.loggedSearchTerms, ["", searchTerm0], "Expect two search term logged after a search request")
        XCTAssertEqual(loader.cancelLoadCallCount, 1, "Expect one cancel load because of the inital uncompleted request")
        
        let searchTerm1 = "term 1"
        sut.simulateSearchPhotos(by: searchTerm1)
        
        XCTAssertEqual(loader.loadCallCount, 3, "Expect three photos loads after search photos again")
        XCTAssertEqual(loader.loggedSearchTerms, ["", searchTerm0, searchTerm1], "Expect three search terms logged after more a search request")
        XCTAssertEqual(loader.cancelLoadCallCount, 2, "Expect two cancel loads because of more an uncompleted search request")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: PhotoSearchViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = PhotoSearchViewController(loadPhotosPublisher: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private class LoaderSpy {
        typealias LoadPublisher = PassthroughSubject<Void, Error>
        
        private var loadRequests = [(publisher: LoadPublisher, searchTerm: String)]()
        var loadCallCount: Int {
            loadRequests.count
        }
        var loggedSearchTerms: [String] {
            loadRequests.map(\.searchTerm)
        }
        
        private(set) var cancelLoadCallCount = 0
        
        func loadPublisher(_ searchTerm: String) -> AnyPublisher<Void, Error> {
            let publisher = LoadPublisher()
            loadRequests.append((publisher, searchTerm))
            return publisher.handleEvents(receiveCancel: { [weak self] in
                self?.cancelLoadCallCount += 1
            }).eraseToAnyPublisher()
        }
        
        func complete(with error: Error, at index: Int) {
            guard index < loadRequests.count else { return }
            loadRequests[index].publisher.send(completion: .failure(error))
        }
    }
    
}

extension PhotoSearchViewController {
    func simulateUserInitiatedReload() {
        refreshControl?.simulate(event: .valueChanged)
    }
    
    func simulateSearchPhotos(by searchTerm: String) {
        searchBar(searchBar, textDidChange: searchTerm)
    }
}
