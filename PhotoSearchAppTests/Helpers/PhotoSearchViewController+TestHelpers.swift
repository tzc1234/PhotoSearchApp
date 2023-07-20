//
//  PhotoSearchViewController+TestHelpers.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 20/07/2023.
//

import UIKit
@testable import PhotoSearchApp

extension PhotoSearchViewController {
    public override func loadViewIfNeeded() {
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
