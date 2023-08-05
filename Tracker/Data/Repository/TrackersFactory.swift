//
//  TrackersFactory.swift
//  Tracker
//
//  Created by Александр Поляков on 03.08.2023.
//

import Foundation

final class TrackersFactory: TrackersStorageProtocol {
    var trackerTitle: String = "Домашний тестовый уют"
    var trackers: [Tracker]? = [Tracker(id: UInt(Date().timeIntervalSince1970),
                                        color: 1,
                                        title: "Тестовый трекер",
                                        icon: 1,
                                        isDoneAt: [SimpleDate(date:Date())])]
    
    
    
    static let shared = TrackersFactory()
    
    private init() {}
    
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
