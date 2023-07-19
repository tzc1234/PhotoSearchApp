//
//  PhotoSearchUIIntegrationTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 18/07/2023.
//

import Combine
import XCTest
@testable import PhotoSearchApp

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
        let photos = [makePhoto(id: "0")]
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
        
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once search request completed with error again")
    }
    
    func test_loadPhotosComplete_doesNotRenderPhotoViewsCompletedWithError() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        assert(sut, isRending: [])
        
        loader.complete(with: anyNSError(), at: 0)
        
        assert(sut, isRending: [])
        
        sut.simulateSearchPhotos(by: anyTerm())
        loader.complete(with: anyNSError(), at: 1)
        
        assert(sut, isRending: [])
    }
    
    func test_loadPhotosComplete_doesNotRenderPhotoViewsCompletedWithEmptyPhotos() {
        let emptyPhotos = [Photo]()
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        assert(sut, isRending: [])
        
        loader.complete(with: emptyPhotos, at: 0)
        
        assert(sut, isRending: emptyPhotos)
        
        sut.simulateSearchPhotos(by: anyTerm())
        loader.complete(with: emptyPhotos, at: 1)
        
        assert(sut, isRending: emptyPhotos)
    }
    
    func test_loadPhotosComplete_rendersPhotoViewsCompletedWithPhotos() {
        let photos0 = [makePhoto(id: "0", title: "title 0"), makePhoto(id: "1", title: "title 1")]
        let photos1 = [makePhoto(id: "2", title: "title 2"), makePhoto(id: "3", title: "title 3")]
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        assert(sut, isRending: [])
        
        loader.complete(with: photos0, at: 0)
        
        assert(sut, isRending: photos0)
        
        sut.simulateSearchPhotos(by: anyTerm())
        loader.complete(with: photos1, at: 1)

        assert(sut, isRending: photos1)
    }
    
    func test_loadPhotosComplete_doesNotAlterCurrentRenderedPhotoViewsOnLoaderError() {
        let photos0 = [makePhoto(id: "0", title: "title 0"), makePhoto(id: "1", title: "title 1")]
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.complete(with: photos0, at: 0)
        
        assert(sut, isRending: photos0)
        
        sut.simulateUserInitiatedReload()
        loader.complete(with: anyNSError(), at: 1)
        
        assert(sut, isRending: photos0)
        
        sut.simulateSearchPhotos(by: anyTerm())
        loader.complete(with: anyNSError(), at: 2)
        
        assert(sut, isRending: photos0)
    }
    
    func test_loadPhotosComplete_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Wait for initial photos load")
        DispatchQueue.global().async {
            loader.complete(with: [], at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadPhotosComplete_showsErrorOnLoaderError() throws {
        let expectedError = LoggedError(title: "Oops!", message: "Network error occurred, please try again.")
        var loggedErrors = [LoggedError]()
        let (sut, loader) = makeSUT(showError: { title, message in
            loggedErrors.append(.init(title: title, message: message))
        })
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loggedErrors.count, 0, "Expect no errors shown before load photos completed")
        
        loader.complete(with: anyNSError(), at: 0)
        
        XCTAssertEqual(loggedErrors, [expectedError], "Expect one error shown after load photos completed with error")
        
        sut.simulateUserInitiatedReload()
        loader.complete(with: [], at: 1)
        
        XCTAssertEqual(loggedErrors.count, 1, "Expect no new error shown after user initiated load photos completed successfully")
        
        sut.simulateSearchPhotos(by: anyTerm())
        
        XCTAssertEqual(loggedErrors.count, 1, "Expect no new error shown before search photos completed")
        
        loader.complete(with: anyNSError(), at: 2)
        
        XCTAssertEqual(loggedErrors, [expectedError, expectedError], "Expect one new error shown after search photos completed with error")
    }
    
    // MARK: - Image View tests
    
    func test_photoImageView_loadImageForPhotoWhenVisiable() {
        let photo0 = makePhoto(id: "0")
        let photo1 = makePhoto(id: "1")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.complete(with: [photo0, photo1], at: 0)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage, [], "Expect no image load before image views rendered")
        
        sut.simulatePhotoImageViewVisiable(at: 0)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage, [photo0], "Expect one image load once first image view is visiable")
        
        sut.simulatePhotoImageViewVisiable(at: 1)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage, [photo0, photo1], "Expect two image load once second image view is visiable")
    }
    
    func test_photoImageView_cancelsImageLoadForPhotoWhenInvisiable() throws {
        let photo0 = makePhoto(id: "0")
        let photo1 = makePhoto(id: "1")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.complete(with: [photo0, photo1], at: 0)
        
        let firstView = try XCTUnwrap(sut.simulatePhotoImageViewVisiable(at: 0))
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage, [photo0], "Expect one image load once first image view is visiable")
        XCTAssertEqual(loader.cancelLoadImageCallCount, 0, "Expect no cancelled image load since no image views are invisible")
        
        sut.simulatePhotoImageViewInvisiable(firstView, at: 0)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage, [photo0], "Expect no new image load since no image view is visible")
        XCTAssertEqual(loader.cancelLoadImageCallCount, 1, "Expect one cancelled image load once first image view is invisible")
        
        let secondView = try XCTUnwrap(sut.simulatePhotoImageViewVisiable(at: 1))
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage, [photo0, photo1], "Expect a new image load since second image view is visible")
        XCTAssertEqual(loader.cancelLoadImageCallCount, 1, "Expect no new cancelled image load since no new image view is invisible")
        
        sut.simulatePhotoImageViewInvisiable(secondView, at: 1)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage, [photo0, photo1], "Expect no new image load since no new image view is visible")
        XCTAssertEqual(loader.cancelLoadImageCallCount, 2, "Expect a new cancelled image load since second image view is invisible")
    }
    
    func test_photoImageView_reloadsImageForPhotoWhenBecomeVisibleAgain() throws {
        let photo0 = makePhoto(id: "0")
        let photo1 = makePhoto(id: "1")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.complete(with: [photo0, photo1], at: 0)
        
        let firstView = try XCTUnwrap(sut.simulatePhotoImageViewVisiable(at: 0))
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage, [photo0], "Expect a image load once first image view is visiable")
        
        sut.simulatePhotoImageViewInvisiable(firstView, at: 0)
        sut.simulatePhotoImageViewBecomeVisiableAgain(firstView, at: 0)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage, [photo0, photo0], "Expect a image reload once first image view becomes visiable again")
        
        let secondView = try XCTUnwrap(sut.simulatePhotoImageViewVisiable(at: 1))
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage,
                       [photo0, photo0, photo1],
                       "Expect a image load for second image view once second image view is visiable")
        
        sut.simulatePhotoImageViewInvisiable(secondView, at: 1)
        sut.simulatePhotoImageViewBecomeVisiableAgain(secondView, at: 1)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage,
                       [photo0, photo0, photo1, photo1],
                       "Expect a image reload for second image view once second image view becomes visiable again")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(showError: @escaping (String, String) -> Void = { _, _ in },
                         file: StaticString = #filePath, line: UInt = #line) -> (sut: PhotoSearchViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = PhotoSearchViewController(loadPhotosPublisher: loader.loadPublisher,
                                            loadImagePublisher: loader.loadImagePublisher,
                                            showError: showError)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assert(_ sut: PhotoSearchViewController, isRending photos: [Photo],
                        file: StaticString = #filePath, line: UInt = #line) {
        guard photos.count == sut.numberOfPhotoViews else {
            XCTFail("Expect \(photos.count) photo views, got \(sut.numberOfPhotoViews) instead", file: file, line: line)
            return
        }
        
        photos.enumerated().forEach { index, photo in
            assert(sut, hasConfigureFor: photo, at: index, file: file, line: line)
        }
    }
    
    private func assert(_ sut: PhotoSearchViewController, hasConfigureFor photo: Photo, at row: Int,
                        file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.photoView(at: row)?.titleText,
                       photo.title,
                       "Expect title: \(photo.title) for row: \(row), got \(String(describing: sut.photoView(at: 0)?.titleText)) instead",
                       file: file,
                       line: line)
    }
    
    private func makePhoto(id: String = "any id", title: String = "any title") -> Photo {
        .init(id: id, title: title)
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
    }
    
    private struct LoggedError: Equatable {
        let title: String
        let message: String
    }
    
}

extension PhotoSearchViewController {
    open override func loadViewIfNeeded() {
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
    
    @discardableResult
    func simulatePhotoImageViewVisiable(at row: Int) -> PhotoCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: indexPath) as? PhotoCell
    }
    
    func simulatePhotoImageViewInvisiable(_ view: UITableViewCell, at row: Int) {
        let d = tableView.delegate
        let indexPath = IndexPath(row: row, section: section)
        d?.tableView?(tableView, didEndDisplaying: view, forRowAt: indexPath)
    }
    
    func simulatePhotoImageViewBecomeVisiableAgain(_ view: UITableViewCell, at row: Int) {
        let d = tableView.delegate
        let indexPath = IndexPath(row: row, section: section)
        d?.tableView?(tableView, willDisplay: view, forRowAt: indexPath)
    }
    
    private var section: Int { 0 }
}

extension PhotoCell {
    var titleText: String? {
        titleLabel.text
    }
}
