//
//  TrackersRecord.swift
//  Tracker
//
//  Created by Александр Поляков on 21.08.2023.
//

import Foundation

protocol TrackersRecord {
    var title: String { get }
    var createdAt: Date { get }
    var categoryId: UUID { get }
    var color: Int { get }
    var icon: Int { get }
    var isPlannedFor: String { get }
}

struct TrackersRecordImpl: TrackersRecord {
    let createdAt: Date
    let categoryId: UUID
    let color: Int
    let icon: Int
    let isPlannedFor: String
    let title: String
}

