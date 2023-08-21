//
//  TrackersRepositoryProtocol.swift
//  Tracker
//
//  Created by Александр Поляков on 06.08.2023.
//

import Foundation
protocol TrackersRepositoryProtocol {
    
    func addNewCategory(name:String)
    func getAllTrackers() -> TrackersSearchResponse
    func getAllCategoriesPlannedTo(date:SimpleDate, titleFilter: String?) -> TrackersSearchResponse
    func addNewTrackerToCategory(color: Int,
                                 categoryID: UUID,
                                 trackerName: String,
                                 icon: Int,
                                 plannedDaysOfWeek: String)
    func interactWithTrackerDoneForDate(trackerId:UUID,
                                        date: SimpleDate)
    
    func howManyDaysIsTrackerDone(trackerId: UUID) -> Int
    func isTrackerDoneAtDate(trackerId: UUID, date: SimpleDate) -> Bool
}
