//
//  LoadMoreCell.swift
//  PhotoSearchApp
//
//  Created by Tsz-Lung on 11/12/2023.
//

import UIKit

final class LoadMoreCell: UITableViewCell {
    private lazy var spinner = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private(set) lazy var stackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isHidden = true
        return stack
    }()
    
    private(set) lazy var titleLabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.font = .preferredFont(forTextStyle: .subheadline)
        lbl.textColor = .label
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private(set) lazy var messageLabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.font = .preferredFont(forTextStyle: .footnote)
        lbl.textColor = .secondaryLabel
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    var isLoading: Bool {
        set { newValue ? spinner.startAnimating() : spinner.stopAnimating() }
        get { spinner.isAnimating }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureLayout()
    }
    
    private func configureLayout() {
        selectionStyle = .none
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        contentView.addSubview(spinner)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).prioritised(749),
            spinner.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).prioritised(749),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) { nil }
}
