//
//  Tracker.swift
//  Tracker
//
//  Created by Александр Поляков on 03.08.2023.
//

import Foundation
struct Tracker {
    let id: UInt
    let color: Int
    let title: String
    let icon: Int
    var isPlannedFor: String // строка вида "137" для отображения дней недели на которые запланирован трекер
    var isDoneAt: Set<SimpleDate>
}
