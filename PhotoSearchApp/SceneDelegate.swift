//
//  SceneDelegate.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 18/07/2023.
//

import Combine
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private lazy var httpClient = URLSessionHTTPClient(session: .shared)
    
    var window: UIWindow?
    private var navigation: UINavigationController?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        let photoSearchController = PhotoSearchComposer.composeWith(
            loadPhotosPublisher: makePhotosPublisher,
            loadImagePublisher: makePhotoImagePublisher,
            showError: showErrorAlert)
        
        navigation = UINavigationController(rootViewController: photoSearchController)
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
    }
    
    private func makePhotosPublisher(searchTerm: String) -> AnyPublisher<[Photo], Error> {
        let apiKey = ""
        assert(!apiKey.isEmpty, "Set flickr api key here.")
        let url = PhotosEndpoint.get(searchTerm: searchTerm).url(apiKey: apiKey)
        return httpClient
            .getPublisher(url: url)
            .tryMap(PhotosResponseConverter.convert)
            .eraseToAnyPublisher()
    }
    
    private func makePhotoImagePublisher(photo: Photo) -> AnyPublisher<Data, Error> {
        let url = PhotoImageEndpoint.get(photo: photo).url
        return httpClient
            .getPublisher(url: url)
            .tryMap(PhotoImageResponseConverter.convert)
            .eraseToAnyPublisher()
    }
    
    private func showErrorAlert(error: PhotoSearchViewController.ErrorMessage) {
        let alert = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        navigation?.present(alert, animated: true)
    }
}

extension HTTPClient {
    typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>
    
    func getPublisher(url: URL) -> Publisher {
        var task: HTTPClientTask?
        
        return Deferred {
            Future { completion in
                task = get(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}
