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
    
    // MARK: - Helpers
    
    private func makeSUT() -> PhotoSearchViewController {
        let sut = PhotoSearchViewController(loadPhotos: loadPhotos, showError: { _ in })
        sut.tableView.showsVerticalScrollIndicator = false
        sut.tableView.showsHorizontalScrollIndicator = false
        sut.loadViewIfNeeded()
        return sut
    }
    
    private func loadPhotos(id: String) {}
    
    private func emptyPhotos() -> [PhotoCellController] {
        []
    }
}
