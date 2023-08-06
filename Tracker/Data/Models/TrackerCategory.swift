//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Александр Поляков on 05.08.2023.
//

import Foundation
class TrackerCategory {
    let id: UInt
    var categoryTitle: String
    var trackers: [Tracker]
    
    init(id: UInt, categoryTitle: String, trackers: [Tracker] = []) {
        self.id = id
        self.categoryTitle = categoryTitle
        self.trackers = trackers
    }
}
