//
//  LoadMoreCell.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 11/12/2023.
//

import UIKit

final class LoadMoreCell: UITableViewCell {
    private(set) lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        return spinner
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureLayout()
    }
    
    private func configureLayout() {
        selectionStyle = .none
        contentView.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            spinner.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) { nil }
}
