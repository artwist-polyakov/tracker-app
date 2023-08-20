//
//  TrackersRepositoryForCoreData.swift
//  Tracker
//
//  Created by Александр Поляков on 19.08.2023.
//

import Foundation
class TrackersRepositoryImplCoreData: TrackersRepositoryProtocol{
    
    static let shared = TrackersRepositoryImplCoreData()
    
    func addNewCategory(name: String) {
        return
    }
    
    func getAllTrackers() -> [TrackerCategory] {
        return []
    }
    
    func getAllCategoriesPlannedTo(date: SimpleDate, titleFilter: String?) -> [TrackerCategory] {
        return []
    }
    
    func addNewTrackerToCategory(color: Int, categoryID: UUID, trackerName: String, icon: Int, plannedDaysOfWeek: String) {
        return
    }
    
    func interactWithTrackerDoneForDate(trackerId: UUID, date: SimpleDate) {
        return
    }
    
    func howManyDaysIsTrackerDone(trackerId: UUID) -> Int {
        return 42
    }
    
    func isTrackerDoneAtDate(trackerId: UUID, date: SimpleDate) -> Bool {
        return true
    }
    

}