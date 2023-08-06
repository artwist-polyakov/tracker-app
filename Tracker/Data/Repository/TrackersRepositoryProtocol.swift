//
//  TrackersRepositoryProtocol.swift
//  Tracker
//
//  Created by Александр Поляков on 06.08.2023.
//

import Foundation
protocol TrackersRepositoryProtocol {
    func addNewCategory(name:String)
    func getAllTrackers() -> [TrackerCategory]
    func getAllCategoriesPlannedTo(date:SimpleDate) -> [TrackerCategory]
    func addNewTrackerToCategory(categoryID: UInt,
                                 trackerName: String,
                                 plannedDaysOfWeek: [String])
    func interactWithTrackerDoneForeDate(trackerId:UInt,
                                         date: SimpleDate)
    
}
