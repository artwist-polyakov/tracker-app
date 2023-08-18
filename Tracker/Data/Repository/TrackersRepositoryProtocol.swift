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
    func getAllCategoriesPlannedTo(date:SimpleDate, titleFilter: String?) -> [TrackerCategory]
    func addNewTrackerToCategory(color: Int,
                                 categoryID: UInt,
                                 trackerName: String,
                                 icon: Int,
                                 plannedDaysOfWeek: String)
    func interactWithTrackerDoneForDate(trackerId:UInt,
                                        date: SimpleDate)
    
    func howManyDaysIsTrackerDone(trackerId: UInt) -> Int
    func isTrackerDoneAtDate(trackerId: UInt, date: SimpleDate) -> Bool
}
