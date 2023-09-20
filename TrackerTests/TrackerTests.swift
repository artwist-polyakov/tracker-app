//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Александр Поляков on 12.09.2023.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    func testMainScreen() {
        let vc = TrackersViewController()
//        vc.view.backgroundColor = .cyan // раскомментировать, чтобы провалить тест.
        assertSnapshot(matching: vc, as: .image)
    }
}
