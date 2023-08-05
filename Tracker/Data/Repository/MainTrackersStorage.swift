//
//  MainTrackersStorage.swift
//  Tracker
//
//  Created by Александр Поляков on 05.08.2023.
//

import Foundation
final class MainTrackerStorage {
    static let shared = MainTrackerStorage()
    var categories: [TrackerCategory]?
}
