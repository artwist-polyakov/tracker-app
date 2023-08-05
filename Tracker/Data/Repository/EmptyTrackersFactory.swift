//
//  TrackersFactory.swift
//  Tracker
//
//  Created by Александр Поляков on 03.08.2023.
//

import Foundation

final class EmptyTrackersFactory: TrackersStorageProtocol {
    var trackerTitle: String = ""
    var trackers: [Tracker] = []
    
    
    
    static let shared = EmptyTrackersFactory()
    
    private init() {}
    
    func addDay(to toPosition: Int, day date: SimpleDate, _ completion: () -> ()) {
        if toPosition > trackers.count {
            print("Некорректный индекс")
            return
        } else {
            trackers[toPosition].isDoneAt.insert(date)
        }
    }
    
    func removeDay(to toPosition: Int, day date: SimpleDate, _ completion: () -> ()) {
        if toPosition > trackers.count {
            print("Некорректный индекс")
            return
        } else {
            trackers[toPosition].isDoneAt.remove(date)
        }
    }
    
    
}
