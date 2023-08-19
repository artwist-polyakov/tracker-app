//
//  Tracker.swift
//  Tracker
//
//  Created by Александр Поляков on 03.08.2023.
//

import Foundation
struct Tracker {
    let id: UUID
    let color: Int
    let title: String
    let icon: Int
    var isPlannedFor: String // строка вида "137" для отображения дней недели на которые запланирован трекер
    var isDoneAt: Set<SimpleDate>
    
    init(color: Int, title: String, icon: Int, isPlannedFor: String, isDoneAt: Set<SimpleDate>) {
        self.id = UUID()
        self.color = color
        self.title = title
        self.icon = icon
        self.isPlannedFor = isPlannedFor
        self.isDoneAt = isDoneAt
    }
}
