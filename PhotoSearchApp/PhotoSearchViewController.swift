//
//  PhotoSearchViewController.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 18/07/2023.
//

import Combine
import UIKit

class PhotoSearchViewController: UITableViewController {
    typealias LoadPhotosPublisher = AnyPublisher<[Photo], Error>
    typealias LoadImagePublisher = AnyPublisher<Data, Error>
    
    private(set) lazy var searchBar = {
        let bar = UISearchBar()
        bar.delegate = self
        return bar
    }()
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, Photo> = {
        .init(tableView: tableView) { [weak self] tableView, indexPath, photo in
            let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier) as! PhotoCell
            cell.titleLabel.text = photo.title
            self?.loadImage(on: cell, forRowAt: indexPath)
            cell.onReuse = { [weak self] in
                self?.cancelImageLoad(forRowAt: indexPath)
            }
            return cell
        }
    }()
    
    private var searchTerm = ""
    private var loadPhotosCancellable: Cancellable?
    private let loadPhotosPublisher: (String) -> LoadPhotosPublisher
    private var loadImageCancellables = [IndexPath: Cancellable]()
    private let loadImagePublisher: (Photo) -> LoadImagePublisher
    private let showError: (String, String) -> Void
    
    init(loadPhotosPublisher: @escaping (String) -> LoadPhotosPublisher, loadImagePublisher: @escaping (Photo) -> LoadImagePublisher,
         showError: @escaping (String, String) -> Void) {
        self.loadPhotosPublisher = loadPhotosPublisher
        self.loadImagePublisher = loadImagePublisher
        self.showError = showError
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
            .receive(on: DispatchQueue.immediateWhenOnMainQueueScheluder)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.showError("Oops!", "Network error occurred, please try again.")
                }
                
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
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelImageLoad(forRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        loadImage(on: cell, forRowAt: indexPath)
    }
    
    private func loadImage(on cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let photo = dataSource.itemIdentifier(for: indexPath), let cell = cell as? PhotoCell else {
            return
        }
        
        cell.containerView.isShimmering = true
        loadImageCancellables[indexPath] = loadImagePublisher(photo)
            .sink(receiveCompletion: { [weak cell] _ in
                cell?.containerView.isShimmering = false
            }, receiveValue: { [weak cell] data in
                cell?.photoImageView.image = UIImage(data: data)
            })
    }
    
    private func cancelImageLoad(forRowAt indexPath: IndexPath) {
        loadImageCancellables[indexPath]?.cancel()
        loadImageCancellables[indexPath] = nil
    }
}

extension PhotoSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTerm = searchText
        loadPhotos()
    }
}
