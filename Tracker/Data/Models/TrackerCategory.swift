//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Александр Поляков on 05.08.2023.
//
import Foundation

class TrackerCategory {
    let id: UUID
    var categoryTitle: String
    var trackers: [Tracker]
    
    init(categoryId: UUID, categoryTitle: String, trackers: [Tracker]) {
        self.id = categoryId
        self.categoryTitle = categoryTitle
        self.trackers = trackers
    }
    
    convenience init(categoryTitle: String, trackers: [Tracker] = []) {
        self.init(categoryId: UUID(), categoryTitle: categoryTitle, trackers: trackers)
    }
    
}
