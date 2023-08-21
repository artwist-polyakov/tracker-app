//
//  Tracker.swift
//  Tracker
//
//  Created by Александр Поляков on 03.08.2023.
//

import Foundation
struct Tracker {
    let id: UUID
    var categoryId: UUID
    let color: Int
    let title: String
    let icon: Int
    var isPlannedFor: String // строка вида "137" для отображения дней недели на которые запланирован трекер
    
    init(categoryId: UUID, color: Int, title: String, icon: Int, isPlannedFor: String) {
        self.id = UUID()
        self.categoryId = categoryId
        self.color = color
        self.title = title
        self.icon = icon
        self.isPlannedFor = isPlannedFor
    }
}
