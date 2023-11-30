//
//  ResourcePresenter.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 30/11/2023.
//

import Foundation

protocol ResourcePresenter {
    associatedtype Resource
    
    func didStartLoading()
    func didFinishLoading(with error: Error)
    func didFinishLoading(with resource: Resource)
}
