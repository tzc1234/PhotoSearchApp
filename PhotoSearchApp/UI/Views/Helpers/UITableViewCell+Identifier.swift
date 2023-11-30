//
//  UITableViewCell+Identifier.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 30/11/2023.
//

import UIKit

extension UITableViewCell {
    static var identifier: String { String(describing: Self.self) }
}
