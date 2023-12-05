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
    
    private func emptyPhotos() -> [PhotoStub] {
        []
    }
    
    private func photosWithContent() -> [PhotoStub] {
        [
            PhotoStub(title: "Short title", image: UIImage.make(withColor: .red)),
            PhotoStub(title: "Multi\nline\ntitle", image: UIImage.make(withColor: .green)),
            PhotoStub(title: "", image: UIImage.make(withColor: .blue))
        ]
    }
    
    private func photosWithFailedImageLoading() -> [PhotoStub] {
        [
            PhotoStub(title: "Title", image: nil),
            PhotoStub(title: "", image: nil)
        ]
    }
}

private extension PhotoSearchViewController {
    func display(_ stubs: [PhotoStub]) {
        display(stubs.map { stub in
            let cell = PhotoCellController(delegate: stub)
            stub.controller = cell
            return CellController(dataSource: cell)
        })
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
