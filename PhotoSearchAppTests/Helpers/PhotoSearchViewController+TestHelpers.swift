//
//  PhotoSearchViewController+TestHelpers.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 20/07/2023.
//

import UIKit
@testable import PhotoSearchApp

extension PhotoSearchViewController {
    func simulateAppearance() {
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
    
    func simulateScrollDown() {
        tableView.setContentOffset(.init(x: 0, y: 1), animated: false)
    }
    
    var isAtTheTop: Bool {
        tableView.contentOffset.y <= 0
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
        cell(at: row, inSection: photosSection) as? PhotoCell
    }
    
    @discardableResult
    func simulatePhotoImageViewVisible(at row: Int) -> PhotoCell? {
        photoView(at: row)
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
    @discardableResult
    func simulateLoadMoreAction(tableViewForTest: UITableView? = nil) -> LoadMoreCell? {
        guard let cell = loadMoreView else { return nil }
        
        let d = tableView.delegate
        let indexPath = IndexPath(row: 0, section: loadMoreSection)
        d?.tableView?(tableViewForTest ?? tableView, willDisplay: cell, forRowAt: indexPath)
        return cell as? LoadMoreCell
    }
    
    func simulateLoadMoreViewInvisible(_ view: UITableViewCell) {
        let d = tableView.delegate
        let indexPath = IndexPath(row: 0, section: loadMoreSection)
        d?.tableView?(tableView, didEndDisplaying: view, forRowAt: indexPath)
    }
    
    var isLastPage: Bool {
        loadMoreView == nil
    }
    
    private var loadMoreView: UITableViewCell? {
        cell(at: 0, inSection: loadMoreSection)
    }
    
    private var loadMoreSection: Int { 1 }
}
