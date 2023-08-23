//
//  TrackersRecord.swift
//  Tracker
//
//  Created by Александр Поляков on 21.08.2023.
//

import Foundation

protocol TrackersRecord {
    var trackerId: UUID { get }
    var title: String { get }
    var creationDate: Date { get }
    var categoryId: UUID { get }
    var color: Int { get }
    var icon: Int { get }
    var shedule: String { get }
}

struct TrackersRecordImpl: TrackersRecord {
    let trackerId: UUID
    let title: String
    let creationDate: Date
    let categoryId: UUID
    let color: Int
    let icon: Int
    let shedule: String
    
    init?(from coreDataObject: TrackersCoreData) {
            guard
                let trackerId = coreDataObject.id,
                let title = coreDataObject.title,
                let creationDate = coreDataObject.creationDate,
                let categoryId = coreDataObject.categoryId
            else { return nil }
            
            self.trackerId = trackerId
            self.title = title
            self.creationDate = creationDate
            self.categoryId = categoryId
            self.color = Int(coreDataObject.color)
            self.icon = Int(coreDataObject.icon)
            self.shedule = coreDataObject.shedule ?? ""
        }
}

