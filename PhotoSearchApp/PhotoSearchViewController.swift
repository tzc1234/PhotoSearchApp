//
//  PhotoSearchViewController.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 18/07/2023.
//

import Combine
import UIKit

final class PhotoSearchViewController: UITableViewController {
    typealias LoadPhotosPublisher = AnyPublisher<[Photo], Error>
    
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
    private var loadPhotosCancellable: Cancellable?
    private let loadPhotosPublisher: (String) -> LoadPhotosPublisher
    private let loadImagePublisher: (Photo) -> PhotoCellController.LoadImagePublisher
    private let showError: (String, String) -> Void
    
    init(loadPhotosPublisher: @escaping (String) -> LoadPhotosPublisher,
         loadImagePublisher: @escaping (Photo) -> PhotoCellController.LoadImagePublisher,
         showError: @escaping (String, String) -> Void) {
        self.loadPhotosPublisher = loadPhotosPublisher
        self.loadImagePublisher = loadImagePublisher
        self.showError = showError
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupRefreshControl()
        loadPhotos()
    }
    
    private func configureTableView() {
        tableView.dataSource = dataSource
        tableView.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.identifier)
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadPhotos), for: .valueChanged)
    }
    
    @objc private func loadPhotos() {
        refreshControl?.beginRefreshing()
        
        loadPhotosCancellable?.cancel()
        loadPhotosCancellable = loadPhotosPublisher(searchTerm)
            .receive(on: DispatchQueue.immediateWhenOnMainQueueScheluder)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.showError("Oops!", "Network error occurred, please try again.")
                }
                
                self?.refreshControl?.endRefreshing()
            }, receiveValue: { [weak self] photos in
                guard let self else { return }
                
                self.display(photos.map { photo in
                    PhotoCellController(photo: photo, loadImagePublisher: self.loadImagePublisher)
                })
            })
    }
    
    private func display(_ cellControllers: [PhotoCellController]) {
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
        loadPhotos()
    }
}
