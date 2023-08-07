//
//  TrackerTypeDelegate.swift
//  Tracker
//
//  Created by Александр Поляков on 06.08.2023.
//

protocol TrackerTypeDelegate: AnyObject {
    
    func didSelectTrackerType(_ type: TrackerType)
    func didSelectTrackerCategory(_ category: TrackerCategory)
    func didSetTrackerTitle(_ title: String)
    func didSetTrackerIcon(_ icon: String)
    func didSetShedulleToFlush(_ shedule: Set<String>)
    func didSetTrackerColorToFlush(_ color: Int)
    func clearAllFlushProperties()
    func realizeAllFlushProperties()
}

enum TrackerType {
    case habit
    case irregularEvent
}