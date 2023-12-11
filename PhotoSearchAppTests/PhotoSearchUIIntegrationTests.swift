//
//  PhotoSearchUIIntegrationTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 18/07/2023.
//

import XCTest
@testable import PhotoSearchApp

final class PhotoSearchUIIntegrationTests: XCTestCase {
    func test_init_doesNotNotifyLoader() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadPhotosCallCount, 0)
    }

    func test_photosLoading_requestsPhotosFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadPhotosCallCount, 0, "Expect zero photos loads before the view rendering completed")
        
        sut.simulateAppearance()
        
        XCTAssertEqual(loader.loadPhotosCallCount, 1, "Expect a photos load after the view rendering completed")
        
        loader.completePhotosLoad(with: [], at: 0)
        sut.simulateUserInitiatedReload()

        XCTAssertEqual(loader.loadPhotosCallCount, 2, "Expect two photos loads after user initiated a photos reload")
        
        loader.completePhotosLoad(with: [], at: 1)
        sut.simulateUserInitiatedReload()
        
        XCTAssertEqual(loader.loadPhotosCallCount, 3, "Expect three photos loads after user initiated second photos reload")
    }
    
    func test_photosSearching_requestsPhotosBySearchTermFromLoader() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        XCTAssertEqual(loader.loggedSearchTerms, [""], "Expect one search term logged after view rendered")
        loader.completePhotosLoad(with: [], at: 0)
        
        let searchTerm0 = "term 0"
        sut.simulateSearchPhotos(by: searchTerm0)
        loader.completePhotosLoad(with: [], at: 1)
        
        XCTAssertEqual(loader.loggedSearchTerms, ["", searchTerm0], "Expect two search terms logged after a search request")
        
        let searchTerm1 = "term 1"
        sut.simulateSearchPhotos(by: searchTerm1)
        loader.completePhotosLoad(with: [], at: 2)
        
        XCTAssertEqual(loader.loggedSearchTerms, ["", searchTerm0, searchTerm1], "Expect three search terms logged after more one search request")
    }
    
    func test_photosSearching_scrollsToTheTopAfterSearching() {
        let photos = [makePhoto()]
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        loader.completePhotosLoad(with: photos, at: 0)
        sut.simulateScrollDown()
        
        XCTAssertFalse(sut.isAtTheTop)
        
        sut.simulateSearchPhotos(by: anyTerm())
        loader.completePhotosLoad(with: photos, at: 1)
        
        XCTAssertTrue(sut.isAtTheTop)
    }
    
    func test_photoSearching_unfocusesSearchBarAfterUserFinishedSearching() {
        let (sut, _) = makeSUT()
        let window = UIWindow()
        window.addSubview(sut.searchBar)
        sut.simulateAppearance()
        sut.simulateFocusOnSearchBar()
        
        XCTAssertTrue(sut.isFocusingOnSearchBar, "Expect focusing on search bar after user focused on it")
        
        sut.simulateSearchBarSearchButtonClicked()
        
        XCTAssertFalse(sut.isFocusingOnSearchBar, "Expect not focusing on search bar after user unfocused on it")
    }
    
    func test_loadingIndicator_showsIndicatorBeforePhotosLoadedCompletedWithError() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect a loading indicator once photos request begins")
        
        loader.completePhotosLoadWithError(at: 0)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once photo request completed with error")
        
        sut.simulateUserInitiatedReload()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect a loading indicator once user initiates photos again")
        
        loader.completePhotosLoadWithError(at: 1)
        sut.simulateSearchPhotos(by: anyTerm())
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect a loading indicator once user searches photos")
        
        loader.completePhotosLoadWithError(at: 2)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once photo request completed with error again")
    }
    
    func test_loadingIndicator_showsIndicatorBeforePhotosLoadedCompletedSuccessfully() {
        let photos = [makePhoto()]
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect a loading indicator once photos request begins")
        
        loader.completePhotosLoad(with: photos, at: 0)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once photo request completed successfully")
        
        sut.simulateUserInitiatedReload() // index 1
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect a loading indicator once user initiates photos again")
        
        loader.completePhotosLoad(with: photos, at: 1)
        sut.simulateSearchPhotos(by: anyTerm()) // index 2
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect a loading indicator once user searches photos")
        
        loader.completePhotosLoad(with: photos, at: 2)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once search request completed successfully")
    }
    
    func test_loadPhotosComplete_doesNotRenderPhotoViewsCompletedWithEmptyPhotos() {
        let emptyPhotos = [Photo]()
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        assert(sut, isRending: emptyPhotos)
        
        loader.completePhotosLoad(with: emptyPhotos, at: 0)
        
        assert(sut, isRending: emptyPhotos)
        
        sut.simulateSearchPhotos(by: anyTerm())
        loader.completePhotosLoad(with: emptyPhotos, at: 1)
        
        assert(sut, isRending: emptyPhotos)
    }
    
    func test_loadPhotosComplete_rendersPhotoViewsCompletedWithPhotos() {
        let photos0 = [makePhoto(id: "0", title: "title 0"), makePhoto(id: "1", title: "title 1")]
        let photos1 = [makePhoto(id: "2", title: "title 2"), makePhoto(id: "3", title: "title 3")]
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        assert(sut, isRending: [])
        
        loader.completePhotosLoad(with: photos0, at: 0)
        
        assert(sut, isRending: photos0)
        
        sut.simulateSearchPhotos(by: anyTerm())
        loader.completePhotosLoad(with: photos1, at: 1)

        assert(sut, isRending: photos1)
    }
    
    func test_loadPhotosComplete_doesNotAlterCurrentRenderedPhotoViewsOnLoaderError() {
        let photos = [makePhoto(id: "0", title: "title 0"), makePhoto(id: "1", title: "title 1")]
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completePhotosLoad(with: photos, at: 0)
        
        assert(sut, isRending: photos)
        
        sut.simulateUserInitiatedReload()
        loader.completePhotosLoadWithError(at: 1)
        loader.completeImageLoad(with: anyImageData(), at: 0)
        loader.completeImageLoad(with: anyImageData(), at: 1)
        
        assert(sut, isRending: photos)
        
        sut.simulateSearchPhotos(by: anyTerm())
        loader.completePhotosLoadWithError(at: 2)
        loader.completeImageLoad(with: anyImageData(), at: 2)
        loader.completeImageLoad(with: anyImageData(), at: 3)
        
        assert(sut, isRending: photos)
    }
    
    func test_loadPhotosComplete_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        let exp = expectation(description: "Wait for initial photos load")
        DispatchQueue.global().async {
            loader.completePhotosLoad(with: [], at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadPhotosComplete_showsErrorOnLoaderError() throws {
        let expectedError = ErrorMessage(title: PhotosPresenter.errorTitle, message: PhotosPresenter.errorMessage)
        var loggedErrors = [ErrorMessage]()
        let (sut, loader) = makeSUT(showError: { loggedErrors.append($0) })
        sut.simulateAppearance()
        
        XCTAssertEqual(loggedErrors.count, 0, "Expect no errors shown before load photos completed")
        
        loader.completePhotosLoadWithError(at: 0)
        
        XCTAssertEqual(loggedErrors, [expectedError], "Expect one error shown after load photos completed with error")
        
        sut.simulateUserInitiatedReload()
        loader.completePhotosLoad(with: [], at: 1)
        
        XCTAssertEqual(loggedErrors.count, 1, "Expect no new error shown after user initiated load photos completed successfully")
        
        sut.simulateSearchPhotos(by: anyTerm())
        
        XCTAssertEqual(loggedErrors.count, 1, "Expect no new error shown before search photos completed")
        
        loader.completePhotosLoadWithError(at: 2)
        
        XCTAssertEqual(loggedErrors, [expectedError, expectedError], "Expect one new error shown after search photos completed with error")
    }
    
    func test_deinit_cancelsPhotoLoadRequestWhenSUTIsDeallocated() {
        let loader = LoaderSpy()
        var sut: PhotoSearchViewController?
        
        autoreleasepool {
            sut = PhotoSearchComposer.composeWith(
                loadPhotosPublisher: loader.loadPhotosPublisher,
                loadImagePublisher: loader.loadImagePublisher,
                showError: { _ in })
            sut?.simulateAppearance()
        }
        
        XCTAssertEqual(loader.cancelLoadCallCount, 0, "Expect no cancel photos load requests before sut is deallocated")
        
        sut = nil
        
        XCTAssertEqual(loader.cancelLoadCallCount, 1, "Expect 1 cancel photos load requests after sut is deallocated")
    }
    
    // MARK: - Load More
    
    func test_loadMorePhotos_requestsLoadMorePhotosFromLoader() {
        let page = [makePhoto(id: "0", title: "title 0"), makePhoto(id: "1", title: "title 1")]
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        loader.completePhotosLoad(with: page, at: 0)
        XCTAssertEqual(loader.loadMorePhotosCallCount, 0, "Expect no load more requests just after the view rendered")
        XCTAssertEqual(loader.loadMorePhotosSearchTerms, [], "Expect no load more search terms logged just after the view rendered")
        
        sut.simulateLoadMoreAction()
        XCTAssertEqual(loader.loadMorePhotosCallCount, 1, "Expect 1 load more request after the 1st load more action")
        XCTAssertEqual(loader.loadMorePhotosSearchTerms, [""], "Expect 1 load more search term logged after the 1st load more action")
        
        sut.simulateLoadMoreAction()
        XCTAssertEqual(loader.loadMorePhotosCallCount, 1, "Expect no change on load more requests after the 1st load more action not yet completed")
        XCTAssertEqual(loader.loadMorePhotosSearchTerms, [""], "Expect no changes on load more search term logged after the 1st load more action not yet completed")

        loader.completeLoadMorePhotos(with: page, isLastPage: false, at: 0)
        XCTAssertEqual(loader.loadMorePhotosCallCount, 1, "Expect no change on load more requests after load more request completed successfully")
        XCTAssertEqual(loader.loadMorePhotosSearchTerms, [""], "Expect no change on load more search terms after load more request completed successfully")
        
        sut.simulateLoadMoreAction()
        XCTAssertEqual(loader.loadMorePhotosCallCount, 2, "Expect 2 load more requests after the 2nd load more action")
        XCTAssertEqual(loader.loadMorePhotosSearchTerms, ["", ""], "Expect 2 load more search terms logged after the 2nd load more action")
        
        loader.completeLoadMorePhotosWithError(at: 1)
        XCTAssertEqual(loader.loadMorePhotosCallCount, 2, "Expect no change on load more requests after load more request completed with error")
        XCTAssertEqual(loader.loadMorePhotosSearchTerms, ["", ""], "Expect no change on load more search terms after load more request completed with error")
        
        sut.simulateLoadMoreAction()
        XCTAssertEqual(loader.loadMorePhotosCallCount, 3, "Expect 3 load more requests after the 3rd load more action")
        XCTAssertEqual(loader.loadMorePhotosSearchTerms, ["", "", ""], "Expect 3 load more search terms logged after the 3rd load more action")
        
        loader.completeLoadMorePhotos(with: page, isLastPage: true, at: 2)
        XCTAssertEqual(loader.loadMorePhotosCallCount, 3, "Expect no change on load more requests after load more request completed successfully")
        XCTAssertEqual(loader.loadMorePhotosSearchTerms, ["", "", ""], "Expect no change on load more search terms after load more request completed successfully")
        
        sut.simulateLoadMoreAction()
        XCTAssertEqual(loader.loadMorePhotosCallCount, 3, "Expect no change on load more requests after the last page is loaded")
        XCTAssertEqual(loader.loadMorePhotosSearchTerms, ["", "", ""], "Expect no change on load more search terms after the last page is loaded")
    }
    
    func test_loadMorePhotos_requestsLoadMorePhotosBySearchTermFromLoader() {
        let page = [makePhoto(id: "0", title: "title 0"), makePhoto(id: "1", title: "title 1")]
        let (sut, loader) = makeSUT()
        let term = "search term"
        let differentTerm = "different search term"
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [], at: 0)
        
        sut.simulateSearchPhotos(by: term)
        loader.completePhotosLoad(with: page, at: 1)
        
        sut.simulateLoadMoreAction()
        XCTAssertEqual(loader.loadMorePhotosCallCount, 1, "Expect 1 load more request after the 1st load more action")
        XCTAssertEqual(loader.loadMorePhotosSearchTerms, [term], "Expect 1 load more search term logged after the 1st load more action")
        
        sut.simulateLoadMoreAction()
        XCTAssertEqual(loader.loadMorePhotosCallCount, 1, "Expect no change on load more requests after the 1st load more action not yet completed")
        XCTAssertEqual(loader.loadMorePhotosSearchTerms, [term], "Expect no changes on load more search term logged after the 1st load more action not yet completed")

        loader.completeLoadMorePhotos(with: page, isLastPage: false, at: 0)
        XCTAssertEqual(loader.loadMorePhotosCallCount, 1, "Expect no change on load more requests after load more request completed successfully")
        XCTAssertEqual(loader.loadMorePhotosSearchTerms, [term], "Expect no change on load more search terms after load more request completed successfully")
        
        sut.simulateLoadMoreAction()
        XCTAssertEqual(loader.loadMorePhotosCallCount, 2, "Expect 2 load more requests after the 2nd load more action")
        XCTAssertEqual(loader.loadMorePhotosSearchTerms, [term, term], "Expect 2 load more search terms logged after the 2nd load more action")
        
        loader.completeLoadMorePhotosWithError(at: 1)
        XCTAssertEqual(loader.loadMorePhotosCallCount, 2, "Expect no change on load more requests after load more request completed with error")
        XCTAssertEqual(loader.loadMorePhotosSearchTerms, [term, term], "Expect no change on load more search terms after load more request completed with error")
        
        sut.simulateLoadMoreAction()
        XCTAssertEqual(loader.loadMorePhotosCallCount, 3, "Expect 3 load more requests after the 3rd load more action")
        XCTAssertEqual(loader.loadMorePhotosSearchTerms, [term, term, term], "Expect 3 load more search terms logged after the 3rd load more action")
        
        loader.completeLoadMorePhotos(with: page, isLastPage: true, at: 2)
        XCTAssertEqual(loader.loadMorePhotosCallCount, 3, "Expect no change on load more requests after load more request completed successfully")
        XCTAssertEqual(loader.loadMorePhotosSearchTerms, [term, term, term], "Expect no change on load more search terms after load more request completed successfully")
        
        sut.simulateLoadMoreAction()
        XCTAssertEqual(loader.loadMorePhotosCallCount, 3, "Expect no change on load more requests after the last page is loaded")
        XCTAssertEqual(loader.loadMorePhotosSearchTerms, [term, term, term], "Expect no change on load more search terms after the last page is loaded")
        
        sut.simulateSearchPhotos(by: differentTerm)
        loader.completePhotosLoad(with: page, at: 2)
        sut.simulateLoadMoreAction()
        XCTAssertEqual(loader.loadMorePhotosCallCount, 4, "Expect 4 load more requests after the 4th load more action with a different search term")
        XCTAssertEqual(loader.loadMorePhotosSearchTerms, [term, term, term, differentTerm], "Expect a different search term logged after the 4th load more action")
    }
    
    func test_loadMorePhotos_showsLoadingIndicatorWhenLoadingMorePhotos() throws {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [], at: 0)
        
        var loadMoreView = try XCTUnwrap(sut.simulateLoadMoreAction())
        
        XCTAssertTrue(loadMoreView.isShowingLoadingIndicator, "Expect a loading indicator after 1st load more request")
        
        loader.completeLoadMorePhotosWithError(at: 0)
        
        XCTAssertFalse(loadMoreView.isShowingLoadingIndicator, "Expect no loading indicator after 1st load more request completed with error")
        
        loadMoreView = try XCTUnwrap(sut.simulateLoadMoreAction())
        
        XCTAssertTrue(loadMoreView.isShowingLoadingIndicator, "Expect a loading indicator after 2nd load more request")
        
        loader.completeLoadMorePhotos(with: [], isLastPage: true, at: 1)
        
        XCTAssertFalse(loadMoreView.isShowingLoadingIndicator, "Expect no loading indicator after 2nd load more request completed successfully")
    }
    
    func test_loadMorePhotos_showsErrorMessageOnLoadMoreError() throws {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [], at: 0)
        
        var loadMoreView = try XCTUnwrap(sut.simulateLoadMoreAction())
        
        XCTAssertNil(loadMoreView.title, "Expect no error title before completion of load more request")
        XCTAssertNil(loadMoreView.message, "Expect no error message before completion of load more request")
        
        loader.completeLoadMorePhotosWithError(at: 0)
        
        XCTAssertEqual(loadMoreView.title, PhotosPresenter.errorTitle, "Expect an error title after load more request completed with error")
        XCTAssertEqual(loadMoreView.message, PhotosPresenter.errorMessage, "Expect an error message after load more request completed with error")
    }
    
    func test_loadMorePhotosComplete_doesNotRenderPhotoViewsCompletedWithEmptyPhotos() {
        let emptyPhotos = [Photo]()
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        loader.completePhotosLoad(with: emptyPhotos, at: 0)
        
        sut.simulateLoadMoreAction()
        loader.completeLoadMorePhotos(with: emptyPhotos, isLastPage: true, at: 0)
        assert(sut, isRending: emptyPhotos)
        
        sut.simulateSearchPhotos(by: anyTerm())
        loader.completePhotosLoad(with: emptyPhotos, at: 1)
        sut.simulateLoadMoreAction()
        loader.completeLoadMorePhotos(with: emptyPhotos, isLastPage: true, at: 1)
        
        assert(sut, isRending: emptyPhotos)
    }
    
    func test_loadMorePhotosComplete_doesNotAlterCurrentRenderedPhotoViewsOnLoaderError() {
        let photos = [makePhoto(id: "0", title: "title 0"), makePhoto(id: "1", title: "title 1")]
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        loader.completePhotosLoad(with: photos, at: 0)
        
        sut.simulateLoadMoreAction()
        loader.completeLoadMorePhotosWithError(at: 0)
        
        assert(sut, isRending: photos)
        
        loader.completeImageLoad(with: anyImageData(), at: 0)
        sut.simulateSearchPhotos(by: anyTerm())
        sut.simulateLoadMoreAction()
        loader.completeLoadMorePhotosWithError(at: 1)
        loader.completeImageLoad(with: anyImageData(), at: 1)
        
        assert(sut, isRending: photos)
    }
    
    func test_loadMorePhotosComplete_rendersPhotoViewsCompletedWithPhotos() {
        let photos0 = [makePhoto(id: "0", title: "title 0"), makePhoto(id: "1", title: "title 1")]
        let photos1 = [makePhoto(id: "2", title: "title 2"), makePhoto(id: "3", title: "title 3")]
        let photos2 = [makePhoto(id: "4", title: "title 4")]
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        loader.completePhotosLoad(with: photos0, at: 0)
        
        sut.simulateLoadMoreAction()
        loader.completeLoadMorePhotos(with: photos0 + photos1, isLastPage: true, at: 0)
        
        assert(sut, isRending: photos0 + photos1)
        
        sut.simulateSearchPhotos(by: anyTerm())
        loader.completePhotosLoad(with: photos0, at: 1)
        
        sut.simulateLoadMoreAction()
        loader.completeLoadMorePhotos(with: photos0 + photos1, isLastPage: false, at: 1)
        
        assert(sut, isRending: photos0 + photos1)

        sut.simulateLoadMoreAction()
        loader.completeLoadMorePhotos(with: photos0 + photos1 + photos2, isLastPage: true, at: 2)
        
        assert(sut, isRending: photos0 + photos1 + photos2)
    }
    
    func test_loadMorePhotosComplete_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [], at: 0)
        
        sut.simulateLoadMoreAction()
        let exp = expectation(description: "Wait for load more photos")
        DispatchQueue.global().async {
            loader.completeLoadMorePhotos(with: [], isLastPage: true, at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadMorePhotos_requestsLoadMoreAgainAfterALoadMoreActionCompletedWithError_whenScrollingLoadMoreViewDown() throws {
        let (sut, loader) = makeSUT()
        let alwaysDraggingTableView = AlwaysDraggingTableView()
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [], at: 0)
        
        let loadMoreView = try XCTUnwrap(sut.simulateLoadMoreAction(tableViewForTest: alwaysDraggingTableView))
        loader.completeLoadMorePhotosWithError(at: 0)
        
        XCTAssertEqual(loader.loadMorePhotosCallCount, 1, "Expect 1 load more request after the 1st load more completed with error")
        
        alwaysDraggingTableView.simulateScrollDown()
        loader.completeLoadMorePhotosWithError(at: 1)
        
        XCTAssertEqual(loader.loadMorePhotosCallCount, 2, "Expect 2 load more requests after the scrolling of the visible load more view")
        
        alwaysDraggingTableView.simulateScrollUp()
        
        XCTAssertEqual(loader.loadMorePhotosCallCount, 2, "Expect no changes on load more requests when scrolling up")
        
        sut.simulateLoadMoreViewInvisible(loadMoreView)
        alwaysDraggingTableView.simulateScrollDown()
        
        XCTAssertEqual(loader.loadMorePhotosCallCount, 2, "Expect no changes on load more requests when scrolling and the load more view is invisible")
    }
    
    // MARK: - Image View tests
    
    func test_photoImageView_loadImageForPhotoWhenVisible() {
        let photo0 = makePhoto(id: "0")
        let photo1 = makePhoto(id: "1")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [photo0, photo1], at: 0)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImageRequest, [], "Expect no image load before image views rendered")
        
        sut.simulatePhotoImageViewVisible(at: 0)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImageRequest, [photo0], "Expect one image load once first image view is visible")
        
        sut.simulatePhotoImageViewVisible(at: 1)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImageRequest, [photo0, photo1], "Expect two image load once second image view is visible")
    }
    
    func test_photoImageView_cancelsImageLoadForPhotoWhenInvisible() throws {
        let photo0 = makePhoto(id: "0")
        let photo1 = makePhoto(id: "1")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [photo0, photo1], at: 0)
        
        let firstView = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 0))
        
        XCTAssertEqual(loader.loggedPhotosForLoadImageRequest, [photo0], "Expect one image load once first image view is visible")
        XCTAssertEqual(loader.loggedPhotosForCancelImageRequest, [], "Expect no cancelled image load since no image views are invisible")
        
        sut.simulatePhotoImageViewInvisible(firstView, at: 0)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImageRequest, [photo0], "Expect no new image load since no image view is visible")
        XCTAssertEqual(loader.loggedPhotosForCancelImageRequest, [photo0], "Expect one cancelled image load once first image view is invisible")
        
        let secondView = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 1))
        
        XCTAssertEqual(loader.loggedPhotosForLoadImageRequest, [photo0, photo1], "Expect a new image load since second image view is visible")
        XCTAssertEqual(loader.loggedPhotosForCancelImageRequest, [photo0], "Expect no new cancelled image load since no new image view is invisible")
        
        sut.simulatePhotoImageViewInvisible(secondView, at: 1)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImageRequest, [photo0, photo1], "Expect no new image load since no new image view is visible")
        XCTAssertEqual(loader.loggedPhotosForCancelImageRequest, [photo0, photo1], "Expect a new cancelled image load since second image view is invisible")
    }
    
    func test_photoImageView_reloadsImageForPhotoWhenBecomeVisibleAgain() throws {
        let photo0 = makePhoto(id: "0")
        let photo1 = makePhoto(id: "1")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [photo0, photo1], at: 0)
        
        let firstView = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 0))
        
        XCTAssertEqual(loader.loggedPhotosForLoadImageRequest, [photo0], "Expect a image load once first image view is visible")
        
        sut.simulatePhotoImageViewInvisible(firstView, at: 0)
        sut.simulatePhotoImageViewBecomeVisibleAgain(firstView, at: 0)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImageRequest, [photo0, photo0], "Expect a image reload once first image view becomes visible again")
        
        let secondView = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 1))
        
        XCTAssertEqual(loader.loggedPhotosForLoadImageRequest,
                       [photo0, photo0, photo1],
                       "Expect a image load for second image view once second image view is visible")
        
        sut.simulatePhotoImageViewInvisible(secondView, at: 1)
        sut.simulatePhotoImageViewBecomeVisibleAgain(secondView, at: 1)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImageRequest,
                       [photo0, photo0, photo1, photo1],
                       "Expect a image reload for second image view once second image view becomes visible again")
    }
    
    func test_photoImageView_rendersLoadedImage() throws {
        let photo0 = makePhoto(id: "0")
        let photo1 = makePhoto(id: "1")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [photo0, photo1], at: 0)
        
        let firstView = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 0))
        let imageData0 = UIImage.makeData(withColor: .red)
        loader.completeImageLoad(with: imageData0, at: 0)
        
        XCTAssertEqual(firstView.renderedImage, imageData0, "Expect rendered image for first image view after first view image load successfully")
        
        let secondView = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 0))
        let imageData1 = UIImage.makeData(withColor: .green)
        loader.completeImageLoad(with: imageData1, at: 1)
        
        XCTAssertEqual(firstView.renderedImage, imageData0, "Expect rendered image for first image no changes")
        XCTAssertEqual(secondView.renderedImage, imageData1, "Expect rendered image for second image view after second view image load successfully")
    }
    
    func test_photoImageView_doesNotRenderInvalidDataImage() throws {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [makePhoto()], at: 0)
        
        let view = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 0))
        let invalidData = Data("invalid data".utf8)
        loader.completeImageLoad(with: invalidData, at: 0)
        
        XCTAssertNil(view.renderedImage, "Expect no rendered image for image view after image load completed with invalid data")
    }
    
    func test_photoImageView_doesNotRenderOnImageLoadError() throws {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [makePhoto()], at: 0)
        
        let view = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 0))
        
        XCTAssertTrue(view.isShowingLoadingIndicator, "Expect a loading before image load completed")
        
        loader.completeImageLoadWithError(at: 0)
        
        XCTAssertNil(view.renderedImage, "Expect no rendered image for image view after image load completed with error")
        XCTAssertFalse(view.isShowingLoadingIndicator, "Expect no loading after image load completed with error")
    }
    
    func test_photoImageView_configuresCorrectlyWhenViewBecomeVisibleAgain() throws {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [makePhoto()], at: 0)
        
        let view = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 0))
        
        XCTAssertNil(view.renderedImage, "Expect no rendered image before image load complete when view is visible")
        XCTAssertTrue(view.isShowingLoadingIndicator, "Expect a loading before image load completed")
        
        sut.simulatePhotoImageViewInvisible(view, at: 0)
        sut.simulatePhotoImageViewBecomeVisibleAgain(view, at: 0)
        
        XCTAssertNil(view.renderedImage, "Expect no rendered image before image reload complete when view becomes visible again")
        XCTAssertTrue(view.isShowingLoadingIndicator, "Expect a loading before image reload completed")
        
        let imageData = UIImage.makeData(withColor: .red)
        loader.completeImageLoad(with: imageData, at: 1)
        
        XCTAssertEqual(view.renderedImage, imageData, "Expect rendered image after image reload completed successfully")
        XCTAssertFalse(view.isShowingLoadingIndicator, "Expect no loading after image reload completed")
    }
    
    func test_photoImageView_doesNotRenderImageWhenItIsInvisible() throws {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [makePhoto()], at: 0)
        
        let view = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 0))
        sut.simulatePhotoImageViewInvisible(view, at: 0)
        loader.completeImageLoad(with: anyImageData(), at: 0)
        
        XCTAssertNil(view.renderedImage, "Expect no rendered image when view is invisible although image load completed successfully")
    }
    
    func test_photoImageView_doesNotRenderImageFromPreviousImageLoadWhenItIsReused() throws {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        let photo0 = makePhoto(id: "0", title: "title 0")
        let photo1 = makePhoto(id: "1", title: "title 1")
        loader.completePhotosLoad(with: [photo0, photo1], at: 0)
        
        let view = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 0)) // image request at 0
        
        XCTAssertEqual(view.titleText, photo0.title, "Expect view set to the first photo title")
        
        sut.simulatePhotoImageViewVisible(at: 1) // image request at 1
        sut.simulatePhotoImageViewBecomeVisibleAgain(view, at: 1)
        view.prepareForReuse()
        
        let afterReusedImageData = UIImage.makeData(withColor: .red)
        loader.completeImageLoad(with: afterReusedImageData, at: 1) // complete the image request which is after reused
        let previousImageData = UIImage.makeData(withColor: .gray)
        loader.completeImageLoad(with: previousImageData, at: 0) // complete the image request which is before reused
        
        XCTAssertEqual(view.renderedImage, afterReusedImageData, "Expect rendered image after view reused when image load completed successfully")
        XCTAssertEqual(view.titleText, photo1.title, "Expect view set the second photo title without changes")
    }
    
    func test_photoImageView_cancelImageRequestAfterViewDeallocated() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        let photo = makePhoto()
        loader.completePhotosLoad(with: [photo], at: 0)
        sut.simulatePhotoImageViewVisible(at: 0)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImageRequest, [photo], "Expect one load photo request after view is visible")
        XCTAssertEqual(loader.loggedPhotosForCancelImageRequest, [], "Expect no cancel photo request after view is visible")
        
        sut.simulateUserInitiatedReload()
        loader.completePhotosLoad(with: [], at: 1)
        
        XCTAssertEqual(sut.numberOfPhotoViews, 0, "Expect no photo view after a user initiated reload")
        XCTAssertEqual(loader.loggedPhotosForLoadImageRequest, [photo], "Expect no changes on load photo requests")
        XCTAssertEqual(loader.loggedPhotosForCancelImageRequest, [photo], "Expect one cancel photo request after photo view is deallocated")
    }
    
    func test_loadImageComplete_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [makePhoto()], at: 0)
        sut.simulatePhotoImageViewVisible(at: 0)
        
        let exp = expectation(description: "Wait for image load completed")
        DispatchQueue.global().async {
            loader.completeImageLoad(with: self.anyImageData(), at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(showError: @escaping (ErrorMessage) -> Void = { _ in },
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: PhotoSearchViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = PhotoSearchComposer.composeWith(
            loadPhotosPublisher: loader.loadPhotosPublisher,
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
        let view = sut.photoView(at: row)
        XCTAssertEqual(
            view?.titleText,
            photo.title,
            "Expect title: \(photo.title) for row: \(row), got \(String(describing: view?.titleText)) instead",
            file: file,
            line: line)
    }
    
    private func anyImageData() -> Data {
        UIImage.makeData(withColor: .gray)
    }
    
    private func anyTerm() -> String {
        "any term"
    }
}
