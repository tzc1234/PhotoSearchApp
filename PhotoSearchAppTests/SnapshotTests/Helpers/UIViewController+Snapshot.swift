//
//  UIViewController+Snapshot.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 05/12/2023.
//

import UIKit

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
    
    struct SnapshotConfiguration {
        let size: CGSize
        let layoutMargins: UIEdgeInsets
        let safeAreaInsets: UIEdgeInsets
        let traitCollection: UITraitCollection
        
        static func iPhone(style: UIUserInterfaceStyle, contentSize: UIContentSizeCategory = .medium) -> Self {
            .init(
                size: CGSize(width: 390, height: 844),
                layoutMargins: UIEdgeInsets(top: 55, left: 8, bottom: 42, right: 8),
                safeAreaInsets: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
                traitCollection: UITraitCollection(traitsFrom: [
                    .init(forceTouchCapability: .unavailable),
                    .init(layoutDirection: .leftToRight),
                    .init(preferredContentSizeCategory: contentSize),
                    .init(userInterfaceIdiom: .phone),
                    .init(horizontalSizeClass: .compact),
                    .init(verticalSizeClass: .regular),
                    .init(accessibilityContrast: .normal),
                    .init(displayScale: 3),
                    .init(displayGamut: .P3),
                    .init(userInterfaceStyle: style)
                ])
            )
        }
    }
    
    private final class SnapshotWindow: UIWindow {
        private var configuration: SnapshotConfiguration = .iPhone(style: .light)
        
        convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
            self.init(frame: .zero)
            self.configuration = configuration
            self.frame.size = configuration.size
            self.layoutMargins = configuration.layoutMargins
            self.rootViewController = UINavigationController(rootViewController: root)
            self.isHidden = false
            root.view.layoutMargins = configuration.layoutMargins
        }
        
        override var safeAreaInsets: UIEdgeInsets {
            configuration.safeAreaInsets
        }
        
        override var traitCollection: UITraitCollection {
            configuration.traitCollection
        }
        
        func snapshot() -> UIImage {
            let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
            return renderer.image { action in
                layer.render(in: action.cgContext)
            }
        }
    }
}
