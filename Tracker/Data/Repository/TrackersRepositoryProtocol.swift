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
                                 plannedDaysOfWeek: Set<String>)
    func interactWithTrackerDoneForDate(trackerId:UInt,
                                        date: SimpleDate)
    
}
