//
//  WeakRefProxy.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 20/07/2023.
//

import Foundation

final class WeakRefProxy<T: AnyObject> {
    private(set) weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}
