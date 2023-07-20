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
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, PhotoCellController> = {
        .init(tableView: tableView) { [weak self] tableView, indexPath, cellController in
            cellController.cell(in: tableView)
        }
    }()
    
    private var searchTerm = ""
    private let loadPhotos: (String) -> Void
    let showError: (String, String) -> Void
    
    init(loadPhotos: @escaping (String) -> Void, showError: @escaping (String, String) -> Void) {
        self.loadPhotos = loadPhotos
        self.showError = showError
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupRefreshControl()
        loadPhotos(searchTerm)
    }
    
    private func configureTableView() {
        tableView.dataSource = dataSource
        tableView.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.identifier)
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reloadPhotos), for: .valueChanged)
    }
    
    @objc private func reloadPhotos() {
        loadPhotos(searchTerm)
    }
    
    func display(_ cellControllers: [PhotoCellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, PhotoCellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(cellControllers)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> PhotoCellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath)?.cancelImageLoad()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath)?.loadImage(on: cell)
    }
}

extension PhotoSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTerm = searchText
        loadPhotos(searchTerm)
    }
}

extension PhotoSearchViewController: PhotosErrorView, PhotosLoadingView {
    func display(_ viewModel: PhotosErrorViewModel) {
        if let title = viewModel.title, let message = viewModel.message {
            showError(title, message)
        }
    }
    
    func display(_ viewModel: PhotosLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
}
