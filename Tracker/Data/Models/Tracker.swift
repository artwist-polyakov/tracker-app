//
//  Tracker.swift
//  Tracker
//
//  Created by Александр Поляков on 03.08.2023.
//

import Foundation
struct Tracker {
    let color: Int
    let title: String
    let icon: Int
    var isDoneAt: Set<SimpleDate>
}
