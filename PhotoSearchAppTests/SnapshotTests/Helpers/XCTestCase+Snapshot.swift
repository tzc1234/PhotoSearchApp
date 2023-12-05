//
//  XCTestCase+Snapshot.swift
//  PhotoSearchAppTests
//
//  Created by Tsz-Lung on 05/12/2023.
//

import XCTest

extension XCTestCase {
    func assert(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
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
        let url = makeSnapshotURL(named: name, file: file)
        
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
    
    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        URL(filePath: String(describing: file))
            .deletingLastPathComponent()
            .appending(component: "snapshots")
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
