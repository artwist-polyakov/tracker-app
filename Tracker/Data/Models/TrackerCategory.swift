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
    
    init(categoryTitle: String) {
        self.id = UUID()
        self.categoryTitle = categoryTitle
    }
}
