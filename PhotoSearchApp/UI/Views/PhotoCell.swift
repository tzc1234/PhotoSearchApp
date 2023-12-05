//
//  PhotoCell.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 18/07/2023.
//

import UIKit

final class PhotoCell: UITableViewCell {
    static var cellHeight: CGFloat { UIScreen.main.bounds.width * 0.56 }
    
    private lazy var shadowBackgroundView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 12
        v.layer.shadowColor = UIColor.secondaryLabel.cgColor
        v.layer.shadowOpacity = 0.9
        v.layer.shadowRadius = 2
        v.layer.shadowOffset = .init(width: 0, height: 3)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private(set) lazy var containerView = {
        let v = ShimmeringView()
        v.backgroundColor = .systemGray3
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.tertiaryLabel.cgColor
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private(set) lazy var photoImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private lazy var placeholderView = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 80)
        let image = UIImage(systemName: "photo", withConfiguration: configuration)
        let iv = UIImageView(image: image)
        iv.tintColor = .secondaryLabel
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private(set) lazy var blurView = {
        let bv = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        bv.translatesAutoresizingMaskIntoConstraints = false
        return bv
    }()
    private(set) lazy var titleLabel = {
        let lbl = UILabel()
        lbl.font = .preferredFont(forTextStyle: .caption1)
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    var onReuse: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func configureUI() {
        selectionStyle = .none
        contentView.addSubview(shadowBackgroundView)
        shadowBackgroundView.addSubview(containerView)
        containerView.addSubview(placeholderView)
        containerView.addSubview(photoImageView)
        containerView.addSubview(blurView)
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            shadowBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            shadowBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            shadowBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            shadowBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            containerView.topAnchor.constraint(equalTo: shadowBackgroundView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: shadowBackgroundView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: shadowBackgroundView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: shadowBackgroundView.bottomAnchor),
            
            placeholderView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            photoImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            blurView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -8),
            blurView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse?()
    }
}
