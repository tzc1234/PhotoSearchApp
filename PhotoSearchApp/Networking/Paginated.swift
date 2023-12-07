//
//  Paginated.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 06/12/2023.
//

import Foundation

struct Paginated<Item> {
    typealias LoadMoreCompletion = (Result<Self, Error>) -> Void
    
    let items: [Item]
    let loadMore: ((String, @escaping LoadMoreCompletion) -> Void)?
}
