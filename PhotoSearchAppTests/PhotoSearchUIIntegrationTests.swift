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
        XCTAssertEqual(loader.cancelLoadCallCount, 0, "Expect zero cancel photos loads before a cancel the view rendering completed")
        
        sut.simulateAppearance()
        
        XCTAssertEqual(loader.loadPhotosCallCount, 1, "Expect a photos load after the view rendering completed")
        
        sut.simulateUserInitiatedReload()

        XCTAssertEqual(loader.loadPhotosCallCount, 2, "Expect two photos loads after user initiated a photos reload")
        XCTAssertEqual(loader.cancelLoadCallCount, 1, "Expect one cancel load after an uncompleted request")
        
        loader.completePhotosLoad(with: anyNSError(), at: 1)
        sut.simulateUserInitiatedReload()
        
        XCTAssertEqual(loader.loadPhotosCallCount, 3, "Expect three photos loads after user initiated second photos reload")
        XCTAssertEqual(loader.cancelLoadCallCount, 1, "Expect no changes because no more request uncompleted")
    }
    
    func test_photosSearching_requestsPhotosWithSearchTermFromLoader() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        XCTAssertEqual(loader.loggedSearchTerms, [""], "Expect one search term logged after view rendered")
        
        let searchTerm0 = "term 0"
        sut.simulateSearchPhotos(by: searchTerm0)
        
        XCTAssertEqual(loader.loadPhotosCallCount, 2, "Expect two photos loads after search photos")
        XCTAssertEqual(loader.loggedSearchTerms, ["", searchTerm0], "Expect two search term logged after a search request")
        XCTAssertEqual(loader.cancelLoadCallCount, 1, "Expect one cancel load because of the inital uncompleted request")
        
        let searchTerm1 = "term 1"
        sut.simulateSearchPhotos(by: searchTerm1)
        
        XCTAssertEqual(loader.loadPhotosCallCount, 3, "Expect three photos loads after search photos again")
        XCTAssertEqual(loader.loggedSearchTerms, ["", searchTerm0, searchTerm1], "Expect three search terms logged after more a search request")
        XCTAssertEqual(loader.cancelLoadCallCount, 2, "Expect two cancel loads because of more an uncompleted search request")
    }
    
    func test_loadingIndicator_showsBeforePhotosLoadedCompletedWithError() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect a loading indicator once photos request begins")
        
        loader.completePhotosLoad(with: anyNSError(), at: 0)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once photo request completed with error")
        
        sut.simulateUserInitiatedReload() // index 1
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect a loading indicator once user initiates photos again")
        
        sut.simulateSearchPhotos(by: anyTerm()) // index 2
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect a loading indicator once user searchs photos")
        
        loader.completePhotosLoad(with: anyNSError(), at: 2)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once photo request completed with error again")
    }
    
    func test_loadingIndicator_showsBeforePhotosLoadedCompletedSuccessfully() {
        let photos = [makePhoto(id: "0")]
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect a loading indicator once photos request begins")
        
        loader.completePhotosLoad(with: photos, at: 0)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once photo request completed successfully")
        
        sut.simulateUserInitiatedReload() // index 1
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect a loading indicator once user initiates photos again")
        
        sut.simulateSearchPhotos(by: anyTerm()) // index 2
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect a loading indicator once user searchs photos")
        
        loader.completePhotosLoad(with: photos, at: 2)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once search request completed successfully")
    }
    
    func test_loadPhotosComplete_doesNotRenderPhotoViewsCompletedWithError() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        assert(sut, isRending: [])
        
        loader.completePhotosLoad(with: anyNSError(), at: 0)
        
        assert(sut, isRending: [])
        
        sut.simulateSearchPhotos(by: anyTerm())
        loader.completePhotosLoad(with: anyNSError(), at: 1)
        
        assert(sut, isRending: [])
    }
    
    func test_loadPhotosComplete_doesNotRenderPhotoViewsCompletedWithEmptyPhotos() {
        let emptyPhotos = [Photo]()
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        assert(sut, isRending: [])
        
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
        loader.completePhotosLoad(with: anyNSError(), at: 1)
        
        assert(sut, isRending: photos)
        
        sut.simulateSearchPhotos(by: anyTerm())
        loader.completePhotosLoad(with: anyNSError(), at: 2)
        
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
        
        loader.completePhotosLoad(with: anyNSError(), at: 0)
        
        XCTAssertEqual(loggedErrors, [expectedError], "Expect one error shown after load photos completed with error")
        
        sut.simulateUserInitiatedReload()
        loader.completePhotosLoad(with: [], at: 1)
        
        XCTAssertEqual(loggedErrors.count, 1, "Expect no new error shown after user initiated load photos completed successfully")
        
        sut.simulateSearchPhotos(by: anyTerm())
        
        XCTAssertEqual(loggedErrors.count, 1, "Expect no new error shown before search photos completed")
        
        loader.completePhotosLoad(with: anyNSError(), at: 2)
        
        XCTAssertEqual(loggedErrors, [expectedError, expectedError], "Expect one new error shown after search photos completed with error")
    }
    
    // MARK: - Image View tests
    
    func test_photoImageView_loadImageForPhotoWhenVisiable() {
        let photo0 = makePhoto(id: "0")
        let photo1 = makePhoto(id: "1")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [photo0, photo1], at: 0)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage, [], "Expect no image load before image views rendered")
        
        sut.simulatePhotoImageViewVisible(at: 0)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage, [photo0], "Expect one image load once first image view is visiable")
        
        sut.simulatePhotoImageViewVisible(at: 1)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage, [photo0, photo1], "Expect two image load once second image view is visiable")
    }
    
    func test_photoImageView_cancelsImageLoadForPhotoWhenInvisiable() throws {
        let photo0 = makePhoto(id: "0")
        let photo1 = makePhoto(id: "1")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [photo0, photo1], at: 0)
        
        let firstView = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 0))
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage, [photo0], "Expect one image load once first image view is visiable")
        XCTAssertEqual(loader.cancelLoadImageCallCount, 0, "Expect no cancelled image load since no image views are invisible")
        
        sut.simulatePhotoImageViewInvisible(firstView, at: 0)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage, [photo0], "Expect no new image load since no image view is visible")
        XCTAssertEqual(loader.cancelLoadImageCallCount, 1, "Expect one cancelled image load once first image view is invisible")
        
        let secondView = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 1))
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage, [photo0, photo1], "Expect a new image load since second image view is visible")
        XCTAssertEqual(loader.cancelLoadImageCallCount, 1, "Expect no new cancelled image load since no new image view is invisible")
        
        sut.simulatePhotoImageViewInvisible(secondView, at: 1)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage, [photo0, photo1], "Expect no new image load since no new image view is visible")
        XCTAssertEqual(loader.cancelLoadImageCallCount, 2, "Expect a new cancelled image load since second image view is invisible")
    }
    
    func test_photoImageView_reloadsImageForPhotoWhenBecomeVisibleAgain() throws {
        let photo0 = makePhoto(id: "0")
        let photo1 = makePhoto(id: "1")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [photo0, photo1], at: 0)
        
        let firstView = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 0))
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage, [photo0], "Expect a image load once first image view is visiable")
        
        sut.simulatePhotoImageViewInvisible(firstView, at: 0)
        sut.simulatePhotoImageViewBecomeVisibleAgain(firstView, at: 0)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage, [photo0, photo0], "Expect a image reload once first image view becomes visiable again")
        
        let secondView = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 1))
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage,
                       [photo0, photo0, photo1],
                       "Expect a image load for second image view once second image view is visiable")
        
        sut.simulatePhotoImageViewInvisible(secondView, at: 1)
        sut.simulatePhotoImageViewBecomeVisibleAgain(secondView, at: 1)
        
        XCTAssertEqual(loader.loggedPhotosForLoadImage,
                       [photo0, photo0, photo1, photo1],
                       "Expect a image reload for second image view once second image view becomes visiable again")
    }
    
    func test_photoImageView_rendersLoadedImage() throws {
        let photo0 = makePhoto(id: "0")
        let photo1 = makePhoto(id: "1")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [photo0, photo1], at: 0)
        
        let firstView = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 0))
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoad(with: imageData0, at: 0)
        
        XCTAssertEqual(firstView.renderedImage, imageData0, "Expect rendered image for first image view after first view image load successfully")
        
        let secondView = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 0))
        let imageData1 = UIImage.make(withColor: .green).pngData()!
        loader.completeImageLoad(with: imageData1, at: 1)
        
        XCTAssertEqual(firstView.renderedImage, imageData0, "Expect rendered image for first image no changes")
        XCTAssertEqual(secondView.renderedImage, imageData1, "Expect rendered image for second image view after second view image load successfully")
    }
    
    func test_photoImageView_doesNotRenderInvalidDataImage() throws {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [makePhoto()], at: 0)
        
        let view = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 0))
        let invalidData = Data("invaliad data".utf8)
        loader.completeImageLoad(with: invalidData, at: 0)
        
        XCTAssertNil(view.renderedImage, "Expect no rendered image for image view after image load completed with invalid data")
    }
    
    func test_photoImageView_doesNotRenderOnImageLoadError() throws {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [makePhoto()], at: 0)
        
        let view = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 0))
        
        XCTAssertTrue(view.isShowingLoadingIndicator, "Expect a loading before image load completed")
        
        loader.completeImageLoad(with: anyNSError(), at: 0)
        
        XCTAssertNil(view.renderedImage, "Expect no rendered image for image view after image load completed with error")
        XCTAssertFalse(view.isShowingLoadingIndicator, "Expect no loading after image load completed with error")
    }
    
    func test_photoImageView_configuresCorrectlyWhenViewBecomeVisibleAgain() throws {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completePhotosLoad(with: [makePhoto()], at: 0)
        
        let view = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 0))
        
        XCTAssertNil(view.renderedImage, "Expect no rendered image before image load complete when view is visiable")
        XCTAssertTrue(view.isShowingLoadingIndicator, "Expect a loading before image load completed")
        
        sut.simulatePhotoImageViewInvisible(view, at: 0)
        sut.simulatePhotoImageViewBecomeVisibleAgain(view, at: 0)
        
        XCTAssertNil(view.renderedImage, "Expect no rendered image before image reload complete when view becomes visiable again")
        XCTAssertTrue(view.isShowingLoadingIndicator, "Expect a loading before image reload completed")
        
        let imageData = UIImage.make(withColor: .red).pngData()!
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
        loader.completePhotosLoad(with: [makePhoto(id: "0"), makePhoto(id: "1")], at: 0)
        
        let view = try XCTUnwrap(sut.simulatePhotoImageViewVisible(at: 0)) // image request at 0
        sut.simulatePhotoImageViewVisible(at: 1) // image request at 1
        
        sut.simulatePhotoImageViewBecomeVisibleAgain(view, at: 1) // view reused at row 1 and become visiable again, image request at 2
        view.prepareForReuse() // then view prepareForReuse
        
        let afterReusedImageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoad(with: afterReusedImageData, at: 2) // complete the reused image request first
        let previousImageData = UIImage.make(withColor: .gray).pngData()!
        loader.completeImageLoad(with: previousImageData, at: 0) // then complete the previous image request
        
        XCTAssertEqual(view.renderedImage, afterReusedImageData, "Expect rendered image after view reused when image load completed successfully")
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
        let sut = PhotoSearchComposer.composeWith(loadPhotosPublisher: loader.loadPhotosPublisher,
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
    
    private func anyImageData() -> Data {
        UIImage.make(withColor: .gray).pngData()!
    }
    
    private func anyTerm() -> String {
        "any term"
    }
}
