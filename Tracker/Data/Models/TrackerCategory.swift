//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Александр Поляков on 05.08.2023.
//

import Foundation
class TrackerCategory: TrackersStorageProtocol {
    let id: UInt
    var categoryTitle: String = ""
    var trackers: [Tracker]?
    
    init(id: UInt, categoryTitle: String) {
        self.id = id
        self.categoryTitle = categoryTitle
    }
    
    func addDay(to toPosition: Int, day date: SimpleDate, _ completion: () -> ()) {
        if toPosition > trackers?.count ?? -1 {
            print("Некорректный индекс")
            return
        } else {
            trackers?[toPosition].isDoneAt.insert(date)
        }
    }
    
    func removeDay(to toPosition: Int, day date: SimpleDate, _ completion: () -> ()) {
        if toPosition > trackers?.count ?? -1 {
            print("Некорректный индекс")
            return
        } else {
            trackers?[toPosition].isDoneAt.remove(date)
        }
    }

}
