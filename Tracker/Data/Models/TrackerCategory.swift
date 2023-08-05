//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Александр Поляков on 05.08.2023.
//

import Foundation
class TrackerCategory: TrackersStorageProtocol {
    
    var trackerTitle: String = ""
    var trackers: [Tracker]?
    
    func addDay(to toPosition: Int, day date: SimpleDate, _ completion: () -> ()) {
        if toPosition > trackers?.count ?? 0 {
            print("Некорректный индекс")
            return
        } else {
            trackers?[toPosition].isDoneAt.insert(date)
        }
    }
    
    func removeDay(to toPosition: Int, day date: SimpleDate, _ completion: () -> ()) {
        if toPosition > trackers?.count {
            print("Некорректный индекс")
            return
        } else {
            trackers?[toPosition].isDoneAt.remove(date)
        }
    }
    
0
}
