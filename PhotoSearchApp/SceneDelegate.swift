//
//  SceneDelegate.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 18/07/2023.
//

import Combine
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private lazy var store = NSCacheDataStore()
    private lazy var imageDataCacher = ImageDataCacher(store: store)
    private lazy var apiKey: String = {
        let key = ""
        assert(!apiKey.isEmpty, "Set Flickr api key here.")
        return key
    }()
    
    var window: UIWindow?
    private var navigation: UINavigationController?
    
    private lazy var httpClient: HTTPClient = URLSessionHTTPClient(session: .shared)
    
    convenience init(httpClient: HTTPClient) {
        self.init()
        self.httpClient = httpClient
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        let photoSearchController = PhotoSearchComposer.composeWith(
            loadPhotosPublisher: makePaginatedPhotosPublisher(),
            loadImagePublisher: makePhotoImagePublisher,
            showError: showErrorAlert)
        
        navigation = UINavigationController(rootViewController: photoSearchController)
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
    }
    
    private func makePaginatedPhotosPublisher(page: Int = 1, photos: [Photo] = []) -> (String) -> AnyPublisher<Paginated<Photo>, Error> {
        return { [apiKey, httpClient, makePaginatedPhotos] searchTerm in
            let url = PhotosEndpoint.get(searchTerm: searchTerm, page: page).url(apiKey: apiKey)
            return httpClient
                .getPublisher(url: url)
                .tryMap(PhotosResponseConverter.convert)
                .map { morePhotos, hasNextPage in
                    let newPhotos = photos + morePhotos
                    return (newPhotos, hasNextPage, page+1)
                }
                .map(makePaginatedPhotos)
                .eraseToAnyPublisher()
        }
    }
    
    private func makePaginatedPhotos(photos: [Photo], hasNextPage: Bool, page: Int) -> Paginated<Photo> {
        print("hasNextPage: \(hasNextPage), page: \(page)" )
        return Paginated(
            items: photos,
            loadMorePublisher: hasNextPage ? makePaginatedPhotosPublisher(page: page, photos: photos) : nil
        )
    }
    
    private func makePhotoImagePublisher(photo: Photo) -> AnyPublisher<Data, Error> {
        let url = PhotoImageEndpoint.get(photo: photo).url
        return imageDataCacher
            .getPublisher(url: url)
            .fallback(to: httpClient
                .getPublisher(url: url)
                .tryMap(PhotoImageResponseConverter.convert)
                .cache(into: imageDataCacher, for: url))
    }
    
    private func showErrorAlert(error: ErrorMessage) {
        let alert = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        navigation?.present(alert, animated: true)
    }
}
