//
//  PhotoCell.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 18/07/2023.
//

import UIKit

class PhotoCell: UITableViewCell {
    private(set) lazy var titleLabel = UILabel()
    static var identifier: String { String(describing: Self.self) }
}
