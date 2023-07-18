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
    typealias LoadPhotosPublisher = AnyPublisher<[Photo], Error>
    
    private(set) lazy var searchBar = {
        let bar = UISearchBar()
        bar.delegate = self
        return bar
    }()
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, Photo> = {
        .init(tableView: tableView) { tableView, indexPath, photo in
            let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier) as! PhotoCell
            cell.titleLabel.text = photo.title
            return cell
        }
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
        
        tableView.dataSource = dataSource
        tableView.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.identifier)
        
        setupRefreshControl()
        loadPhotos()
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadPhotos), for: .valueChanged)
    }
    
    @objc private func loadPhotos() {
        refreshControl?.beginRefreshing()
        
        loadPhotosCancellable?.cancel()
        loadPhotosCancellable = loadPhotosPublisher(searchTerm)
            .sink(receiveCompletion: { [weak self] completion in
                self?.refreshControl?.endRefreshing()
            }, receiveValue: { [weak self] photos in
                self?.display(photos)
            })
    }
    
    private func display(_ photos: [Photo]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Photo>()
        snapshot.appendSections([0])
        snapshot.appendItems(photos)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTerm = searchText
        loadPhotos()
    }
}

class PhotoCell: UITableViewCell {
    private(set) lazy var titleLabel = UILabel()
    static var identifier: String { String(describing: Self.self) }
}

struct Photo: Equatable, Hashable {
    let id: String
    let title: String
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
    
    func test_loadingIndicator_showsBeforePhotosLoadedCompletedWithError() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect a loading indicator once photos request begins")
        
        loader.complete(with: anyNSError(), at: 0)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once photo request completed with error")
        
        sut.simulateUserInitiatedReload() // index 1
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect a loading indicator once user initiates photos again")
        
        sut.simulateSearchPhotos(by: anyTerm()) // index 2
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect a loading indicator once user searchs photos")
        
        loader.complete(with: anyNSError(), at: 2)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once photo request completed with error again")
    }
    
    func test_loadingIndicator_showsBeforePhotosLoadedCompletedSuccessfully() {
        let photos = [Photo(id: "0", title: "any title")]
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect a loading indicator once photos request begins")
        
        loader.complete(with: photos, at: 0)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once photo request completed with error")
        
        sut.simulateUserInitiatedReload() // index 1
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect a loading indicator once user initiates photos again")
        
        sut.simulateSearchPhotos(by: anyTerm()) // index 2
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect a loading indicator once user searchs photos")
        
        loader.complete(with: photos, at: 2)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once photo request completed with error again")
    }
    
    func test_loadPhotosComplete_doesNotRenderPhotoViewsCompletedWithError() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.numberOfPhotoViews, 0, "Expect no photo views rendered before photos loaded")
        
        loader.complete(with: anyNSError(), at: 0)
        
        XCTAssertEqual(sut.numberOfPhotoViews, 0, "Expect no photo views rendered while completed with error")
        
        sut.simulateSearchPhotos(by: anyTerm())
        loader.complete(with: anyNSError(), at: 1)
        
        XCTAssertEqual(sut.numberOfPhotoViews, 0, "Expect no photo views rendered while completed search request with error")
    }
    
    func test_loadPhotosComplete_doesNotRenderPhotoViewsCompletedWithEmptyPhotos() {
        let emptyPhotos = [Photo]()
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.numberOfPhotoViews, 0, "Expect no photo views rendered before photos loaded")
        
        loader.complete(with: emptyPhotos, at: 0)
        
        XCTAssertEqual(sut.numberOfPhotoViews, 0, "Expect no photo views rendered while completed with error")
        
        sut.simulateSearchPhotos(by: anyTerm())
        loader.complete(with: emptyPhotos, at: 1)
        
        XCTAssertEqual(sut.numberOfPhotoViews, 0, "Expect no photo views rendered while completed search request with error")
    }
    
    func test_loadPhotosComplete_rendersPhotoViewsCompletedWithNonEmptyPhotos() {
        let photos0 = [Photo(id: "0", title: "title 0"), Photo(id: "1", title: "title 1")]
        let photos1 = [Photo(id: "2", title: "title 2"), Photo(id: "3", title: "title 3")]
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.numberOfPhotoViews, 0, "Expect no photo views rendered before photos loaded")
        
        loader.complete(with: photos0, at: 0)
        
        XCTAssertEqual(sut.numberOfPhotoViews, 2, "Expect two photo views rendered while completed successfully")
        XCTAssertEqual(sut.photoView(at: 0)?.titleText, photos0[0].title)
        XCTAssertEqual(sut.photoView(at: 1)?.titleText, photos0[1].title)
        
        sut.simulateSearchPhotos(by: anyTerm())
        loader.complete(with: photos1, at: 1)

        XCTAssertEqual(sut.numberOfPhotoViews, 2, "Expect two photo views rendered while completed search request successfully")
        XCTAssertEqual(sut.photoView(at: 0)?.titleText, photos1[0].title)
        XCTAssertEqual(sut.photoView(at: 1)?.titleText, photos1[1].title)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: PhotoSearchViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = PhotoSearchViewController(loadPhotosPublisher: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func anyTerm() -> String {
        "any term"
    }

    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private class LoaderSpy {
        typealias LoadPublisher = PassthroughSubject<[Photo], Error>
        
        private var loadRequests = [(publisher: LoadPublisher, searchTerm: String)]()
        var loadCallCount: Int {
            loadRequests.count
        }
        var loggedSearchTerms: [String] {
            loadRequests.map(\.searchTerm)
        }
        
        private(set) var cancelLoadCallCount = 0
        
        func loadPublisher(_ searchTerm: String) -> AnyPublisher<[Photo], Error> {
            let publisher = LoadPublisher()
            loadRequests.append((publisher, searchTerm))
            return publisher.handleEvents(receiveCancel: { [weak self] in
                self?.cancelLoadCallCount += 1
            }).eraseToAnyPublisher()
        }
        
        func complete(with photos: [Photo], at index: Int) {
            guard index < loadRequests.count else { return }
            
            loadRequests[index].publisher.send(photos)
            loadRequests[index].publisher.send(completion: .finished)
        }
        
        func complete(with error: Error, at index: Int) {
            guard index < loadRequests.count else { return }
            loadRequests[index].publisher.send(completion: .failure(error))
        }
    }
    
}

extension PhotoSearchViewController {
    override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        
        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 9999)
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulate(event: .valueChanged)
    }
    
    func simulateSearchPhotos(by searchTerm: String) {
        searchBar(searchBar, textDidChange: searchTerm)
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    var numberOfPhotoViews: Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }

    func photoView(at row: Int) -> PhotoCell? {
        let indexPath = IndexPath(row: row, section: section)
        return tableView.cellForRow(at: indexPath) as? PhotoCell
    }
    
    private var section: Int { 0 }
}

extension PhotoCell {
    var titleText: String? {
        titleLabel.text
    }
}
