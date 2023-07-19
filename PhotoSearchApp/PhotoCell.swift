//
//  PhotoCell.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 18/07/2023.
//

import UIKit

class PhotoCell: UITableViewCell {
    private(set) lazy var titleLabel = UILabel()
    private(set) lazy var containerView = UIView()
    private(set) lazy var photoImageView = UIImageView()
    
    var onReuse: (() -> Void)?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse?()
    }
    
    static var identifier: String { String(describing: Self.self) }
}
