//
//  PhotoSearchViewSnapshotTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 05/12/2023.
//

import XCTest
@testable import PhotoSearchApp

final class PhotoSearchViewSnapshotTests: XCTestCase {
    func tests_emptyPhotos() {
        let sut = makeSUT()
        
        sut.display(emptyPhotos())
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "EMPTY_PHOTOS_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "EMPTY_PHOTOS_dark")
    }
    
    func test_photosWithContent() {
        let sut = makeSUT()
        
        sut.display(photosWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "PHOTOS_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "PHOTOS_WITH_CONTENT_dark")
    }
    
    func test_photosWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(photosWithFailedImageLoading())
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "PHOTOS_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "PHOTOS_WITH_FAILED_IMAGE_LOADING_dark")
    }
    
    func test_loadingMorePhotos() {
        let sut = makeSUT()
        
        sut.display(loadingMorePhotos())
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LOADING_MORE_PHOTOS_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LOADING_MORE_PHOTOS_dark")
    }
    
    func test_loadMorePhotosError() {
        let sut = makeSUT()
        
        sut.display(loadMorePhotosError())
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LOAD_MORE_PHOTOS_ERROR_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LOAD_MORE_PHOTOS_ERROR_dark")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> PhotoSearchViewController {
        let sut = PhotoSearchViewController(loadPhotos: loadPhotos, showError: { _ in })
        PhotoCellController.configure(tableView: sut.tableView)
        sut.tableView.showsVerticalScrollIndicator = false
        sut.tableView.showsHorizontalScrollIndicator = false
        sut.loadViewIfNeeded()
        return sut
    }
    
    private func loadPhotos(id: String) {}
    
    private func emptyPhotos() -> [CellController] { [] }
    
    private func photosWithContent() -> [CellController] {
        [
            PhotoStub(title: "Short title", image: UIImage.make(withColor: .red)),
            PhotoStub(title: "Multi\nline\ntitle", image: UIImage.make(withColor: .green)),
            PhotoStub(title: "", image: UIImage.make(withColor: .blue))
        ].toCellControllers
    }
    
    private func photosWithFailedImageLoading() -> [CellController] {
        [
            PhotoStub(title: "Title", image: nil),
            PhotoStub(title: "", image: nil)
        ].toCellControllers
    }
    
    private func loadingMorePhotos() -> [[CellController]] {
        let loadMore = LoadMoreCellController(loadMore: {})
        loadMore.display(PhotosLoadingViewModel(isLoading: true))
        return [
            Array(photosWithContent().prefix(2)),
            [CellController(loadMore)]
        ]
    }
    
    private func loadMorePhotosError() -> [[CellController]] {
        let loadMore = LoadMoreCellController(loadMore: {})
        loadMore.display(PhotosLoadingViewModel(isLoading: false))
        loadMore.display(PhotosErrorViewModel(message: ErrorMessage(
            title: "Error Title",
            message: "This a multiline\nerror message.")))
        return [
            Array(photosWithContent().prefix(2)),
            [CellController(loadMore)]
        ]
    }
}

private extension PhotoSearchViewController {
    func display(_ sections: [[CellController]]) {
        if sections.count == 2 {
            display(sections.first!, sections.last!)
        } else {
            display(sections.first!)
        }
    }
}

private extension [PhotoStub] {
    var toCellControllers: [CellController] {
        map { stub in
            let cell = PhotoCellController(delegate: stub)
            stub.controller = cell
            return CellController(cell)
        }
    }
}

private final class PhotoStub: PhotoCellControllerDelegate {
    private let viewModel: PhotoImageViewModel<UIImage>
    weak var controller: PhotoCellController?
    
    init(title: String, image: UIImage?) {
        self.viewModel = .init(title: title, image: image)
    }
    
    func load() {
        controller?.display(PhotoImageLoadingViewModel(isLoading: false))
        controller?.display(viewModel)
    }
    
    func cancel() {}
}
