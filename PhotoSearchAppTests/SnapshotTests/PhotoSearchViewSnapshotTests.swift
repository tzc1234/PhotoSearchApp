//
//  PhotoSearchViewSnapshotTests.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 05/12/2023.
//

import XCTest
@testable import PhotoSearchApp

final class PhotoSearchViewSnapshotTests: XCTestCase {
    func tests_emptyPhotos() {
        let sut = makeSUT()
        
        sut.display(emptyPhotos())
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "EMPTY_PHOTOS_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "EMPTY_PHOTOS_dark")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> PhotoSearchViewController {
        let sut = PhotoSearchViewController(loadPhotos: loadPhotos, showError: { _ in })
        sut.tableView.showsVerticalScrollIndicator = false
        sut.tableView.showsHorizontalScrollIndicator = false
        sut.loadViewIfNeeded()
        return sut
    }
    
    private func loadPhotos(id: String) {}
    
    private func emptyPhotos() -> [PhotoCellController] {
        []
    }
    
    func assert(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail(
                "Cannot find stored snapshot at URL: \(snapshotURL). Use `record` to store a snapshot before asserting.",
                file: file,
                line: line)
            return
        }
        
        let snapshotData = makeSnapshotData(for: snapshot)
        if snapshotData != storedSnapshotData {
            let tempSnapshotURL = URL(filePath: NSTemporaryDirectory(), directoryHint: .isDirectory)
                .appending(component: snapshotURL.lastPathComponent)
            try? snapshotData?.write(to: tempSnapshotURL)
            
            XCTFail(
                "New snapshot does not match stored snapshot. New snapshot: \(tempSnapshotURL), stored snapshot: \(snapshotURL)",
                file: file,
                line: line)
        }
    }
    
    func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let data = makeSnapshotData(for: snapshot)
        let url = makeSnapshotURL(named: name)
        
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true)
            try data?.write(to: url)
            
            XCTFail("Record succeeded, use `assert` to compare the snapshot.", file: file, line: line)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
    
    private func makeSnapshotURL(named name: String, file: StaticString = #filePath) -> URL {
        URL(filePath: String(describing: file))
            .deletingLastPathComponent()
            .appending(component: "snapshot")
            .appending(components: "\(name).png")
    }
    
    private func makeSnapshotData(for snapshot: UIImage, file: StaticString = #filePath, line: UInt = #line) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Fail to generate PNG data from snapshot", file: file, line: line)
            return nil
        }
        
        return data
    }
}

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
            self.rootViewController = root
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
