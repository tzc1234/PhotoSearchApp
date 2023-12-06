//
//  CombineHelpers.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 19/07/2023.
//

import Combine
import Foundation

extension Paginated {
    init(items: [Item], loadMorePublisher: ((String) -> AnyPublisher<Self, Error>)?) {
        self.init(items: items, loadMore: loadMorePublisher.map { publisher in
            return { searchTerm, completion in
                publisher(searchTerm).subscribe(Subscribers.Sink(receiveCompletion: { result in
                    if case let .failure(error) = result {
                        completion(.failure(error))
                    }
                }, receiveValue: { paginatedItems in
                    completion(.success(paginatedItems))
                }))
            }
        })
    }
    
    var loadMorePublisher: ((String) -> AnyPublisher<Self, Error>)? {
        guard let loadMore else { return nil }
        
        return { searchTerm in
            Deferred {
                Future { completion in
                    loadMore(searchTerm, completion)
                }
            }
            .eraseToAnyPublisher()
        }
    }
}

extension Publisher where Output == Data, Failure == Error {
    func cache(into cacher: ImageDataCacher, for url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cacher.saveIgnoringCompletion(data, for: url)
        })
        .eraseToAnyPublisher()
    }
    
    func fallback(to publisher: Self) -> AnyPublisher<Output, Failure> {
        self.catch { _ in publisher }.eraseToAnyPublisher()
    }
}

extension ImageDataCacher {
    func saveIgnoringCompletion(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
    
    func getPublisher(url: URL) -> AnyPublisher<Data, Error> {
        var task: ImageDataCacherTask?
        
        return Deferred {
            Future { completion in
                task = self.loadData(for: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
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

extension DispatchQueue {
    static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
        .shared
    }
    
    struct ImmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions

        var now: SchedulerTimeType {
            DispatchQueue.main.now
        }

        var minimumTolerance: SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }

        func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            guard Thread.isMainThread else {
                DispatchQueue.main.schedule(options: options, action)
                return
            }

            action()
        }

        func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }

        func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
        
        static let shared = Self()
    }
}
