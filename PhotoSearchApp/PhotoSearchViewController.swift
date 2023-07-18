//
//  PhotoSearchViewController.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 18/07/2023.
//

import Combine
import UIKit

class PhotoSearchViewController: UITableViewController, UISearchBarDelegate {
    typealias LoadPhotosPublisher = AnyPublisher<[Photo], Error>
    
    private(set) lazy var searchBar = {
        let bar = UISearchBar()
        bar.delegate = self
        return bar
    }()
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, Photo> = {
        .init(tableView: tableView) { tableView, indexPath, photo in
            let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier) as! PhotoCell
            cell.titleLabel.text = photo.title
            return cell
        }
    }()
    
    private var searchTerm = ""
    private var loadPhotosCancellable: Cancellable?
    private let loadPhotosPublisher: (String) -> LoadPhotosPublisher
    
    init(loadPhotosPublisher: @escaping (String) -> LoadPhotosPublisher) {
        self.loadPhotosPublisher = loadPhotosPublisher
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = dataSource
        tableView.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.identifier)
        
        setupRefreshControl()
        loadPhotos()
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadPhotos), for: .valueChanged)
    }
    
    @objc private func loadPhotos() {
        refreshControl?.beginRefreshing()
        
        loadPhotosCancellable?.cancel()
        loadPhotosCancellable = loadPhotosPublisher(searchTerm)
            .sink(receiveCompletion: { [weak self] completion in
                self?.refreshControl?.endRefreshing()
            }, receiveValue: { [weak self] photos in
                self?.display(photos)
            })
    }
    
    private func display(_ photos: [Photo]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Photo>()
        snapshot.appendSections([0])
        snapshot.appendItems(photos)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTerm = searchText
        loadPhotos()
    }
}
