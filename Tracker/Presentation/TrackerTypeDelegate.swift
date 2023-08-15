//
//  TrackerTypeDelegate.swift
//  Tracker
//
//  Created by Александр Поляков on 06.08.2023.
//

protocol TrackerTypeDelegate: AnyObject {
    
    func didSelectTrackerType(_ type: TrackerType)
    func didSelectTrackerCategory(_ categoryId: UInt)
    func didSetTrackerTitle(_ title: String)
    func didSetTrackerIcon(_ icon: String)
    func didSetShedulleToFlush(_ shedule: Set<Int>)
    func didSetTrackerColorToFlush(_ color: Int)
    func clearAllFlushProperties()
    func realizeAllFlushProperties()
    func giveMeSelectedCategory() -> TrackerCategory
    func giveMeSelectedDays() -> Set<Int>
    func isReadyToFlush() -> Bool
}

enum TrackerType {
    case habit
    case irregularEvent
    case notSet
}
