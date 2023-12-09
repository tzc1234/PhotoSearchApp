//
//  PhotoSearchViewController.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 18/07/2023.
//

import UIKit

final class PhotoSearchViewController: UITableViewController {
    private(set) lazy var searchBar = {
        let bar = UISearchBar()
        bar.delegate = self
        return bar
    }()
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
        .init(tableView: tableView) { tableView, indexPath, cellController in
            cellController.dataSource.tableView(tableView, cellForRowAt: indexPath)
        }
    }()
    
    private(set) var searchTerm = ""
    private var onViewIsAppearing: ((PhotoSearchViewController) -> Void)?
    private var topContentOffset: CGFloat = 0
    
    private let loadPhotos: (String) -> Void
    private let showError: (ErrorMessage) -> Void
    
    init(loadPhotos: @escaping (String) -> Void, showError: @escaping (ErrorMessage) -> Void) {
        self.loadPhotos = loadPhotos
        self.showError = showError
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBar
        configureTableView()
        setupRefreshControl()
        onViewIsAppearing = { vc in
            vc.loadPhotos(vc.searchTerm)
            vc.onViewIsAppearing = nil
            vc.topContentOffset = vc.tableView.contentOffset.y
        }
    }
    
    private func configureTableView() {
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reloadPhotos), for: .valueChanged)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?(self)
    }
    
    @objc private func reloadPhotos() {
        loadPhotos(searchTerm)
    }
    
    func display(_ sections: [CellController]...) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        sections.enumerated().forEach { section, cellControllers in
            snapshot.appendSections([section])
            snapshot.appendItems(cellControllers, toSection: section)
        }
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath)?.delegate.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath)?.delegate.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
}

extension PhotoSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTerm = searchText
        loadPhotos(searchTerm)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

extension PhotoSearchViewController: PhotosErrorView {
    func display(_ viewModel: PhotosErrorViewModel) {
        viewModel.message.map(showError)
    }
}

extension PhotoSearchViewController: PhotosLoadingView {
    func display(_ viewModel: PhotosLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
            scrollToTheTop()
        }
    }
    
    private func scrollToTheTop() {
        tableView.setContentOffset(.init(x: 0, y: topContentOffset), animated: false)
    }
}
