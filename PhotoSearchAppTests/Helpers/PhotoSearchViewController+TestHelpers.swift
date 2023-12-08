//
//  PhotoSearchViewController+TestHelpers.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 20/07/2023.
//

import UIKit
@testable import PhotoSearchApp

extension PhotoSearchViewController {
    func simulateAppearance(tableViewFrame: CGRect = CGRect(x: 0, y: 0, width: 390, height: 9999)) {
        tableView.frame = tableViewFrame
        replaceRefreshControlToSpyForiOS17Support()
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    private func replaceRefreshControlToSpyForiOS17Support() {
        let refreshControlSpy = RefreshControlSpy()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                refreshControlSpy.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = refreshControlSpy
    }
    
    func setTableHeightToLimitCellViewRendering(_ height: CGFloat) {
        tableView.frame = CGRect(x: 0, y: 0, width: 390, height: height)
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulate(event: .valueChanged)
    }
    
    func simulateSearchPhotos(by searchTerm: String) {
        searchBar(searchBar, textDidChange: searchTerm)
    }
    
    func simulateFocusOnSearchBar() {
        searchBar.becomeFirstResponder()
    }
    
    func simulateSearchBarSearchButtonClicked() {
        searchBarSearchButtonClicked(searchBar)
    }
    
    var isFocusingOnSearchBar: Bool {
        searchBar.isFirstResponder
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    private func cell(at row: Int, inSection section: Int) -> UITableViewCell? {
        guard numberOfRows(inSection: section) > row else { return nil }
        
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
    
    private func numberOfRows(inSection section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }
}

extension PhotoSearchViewController {
    var numberOfPhotoViews: Int {
        numberOfRows(inSection: photosSection)
    }
    
    func photoView(at row: Int) -> PhotoCell? {
        let indexPath = IndexPath(row: row, section: photosSection)
        return tableView.cellForRow(at: indexPath) as? PhotoCell
    }
    
    @discardableResult
    func simulatePhotoImageViewVisible(at row: Int) -> PhotoCell? {
        cell(at: row, inSection: photosSection) as? PhotoCell
    }
    
    func simulatePhotoImageViewInvisible(_ view: UITableViewCell, at row: Int) {
        let d = tableView.delegate
        let indexPath = IndexPath(row: row, section: photosSection)
        d?.tableView?(tableView, didEndDisplaying: view, forRowAt: indexPath)
    }
    
    func simulatePhotoImageViewBecomeVisibleAgain(_ view: UITableViewCell, at row: Int) {
        let d = tableView.delegate
        let indexPath = IndexPath(row: row, section: photosSection)
        d?.tableView?(tableView, willDisplay: view, forRowAt: indexPath)
    }
    
    private var photosSection: Int { 0 }
}

extension PhotoSearchViewController {
    func simulateLoadMoreAction() {
        guard let cell = loadMoreView else { return }
        
        let d = tableView.delegate
        let indexPath = IndexPath(row: 0, section: loadMoreSection)
        d?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    var loadMoreView: UITableViewCell? {
        cell(at: 0, inSection: loadMoreSection)
    }
    
    private var loadMoreSection: Int { 1 }
}

final class RefreshControlSpy: UIRefreshControl {
    private var _isRefreshing = false
    
    override var isRefreshing: Bool {
        _isRefreshing
    }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}
