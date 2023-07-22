//
//  PhotoCell.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 18/07/2023.
//

import UIKit

final class PhotoCell: UITableViewCell {
    private(set) lazy var shadowBackgroundView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 12
        v.layer.shadowColor = UIColor.systemGray3.cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 2
        v.layer.shadowOffset = .init(width: 0, height: 3)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private(set) lazy var containerView = {
        let v = UIView()
        v.backgroundColor = .systemGray5
        v.layer.cornerRadius = 12
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
        let configuration = UIImage.SymbolConfiguration(pointSize: 75)
        let image = UIImage(systemName: "photo", withConfiguration: configuration)
        let iv = UIImageView(image: image)
        iv.tintColor = .secondaryLabel
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private lazy var blurView = {
        let bv = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        bv.translatesAutoresizingMaskIntoConstraints = false
        return bv
    }()
    private(set) lazy var titleLabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .caption1)
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
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
            shadowBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            shadowBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            shadowBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            shadowBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
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
    
    static var identifier: String { String(describing: Self.self) }
}
