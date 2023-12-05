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
        
        makeHigherTableFrameToRenderCellSuccessfully()
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
    
    private func makeHigherTableFrameToRenderCellSuccessfully() {
        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 9999)
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
    
    var numberOfPhotoViews: Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }

    func photoView(at row: Int) -> PhotoCell? {
        let indexPath = IndexPath(row: row, section: section)
        return tableView.cellForRow(at: indexPath) as? PhotoCell
    }
    
    @discardableResult
    func simulatePhotoImageViewVisible(at row: Int) -> PhotoCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: indexPath) as? PhotoCell
    }
    
    func simulatePhotoImageViewInvisible(_ view: UITableViewCell, at row: Int) {
        let d = tableView.delegate
        let indexPath = IndexPath(row: row, section: section)
        d?.tableView?(tableView, didEndDisplaying: view, forRowAt: indexPath)
    }
    
    func simulatePhotoImageViewBecomeVisibleAgain(_ view: UITableViewCell, at row: Int) {
        let d = tableView.delegate
        let indexPath = IndexPath(row: row, section: section)
        d?.tableView?(tableView, willDisplay: view, forRowAt: indexPath)
    }
    
    private var section: Int { 0 }
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
