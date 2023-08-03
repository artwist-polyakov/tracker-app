//
//  TrackersFactory.swift
//  Tracker
//
//  Created by Александр Поляков on 03.08.2023.
//

import Foundation

final class TrackersFactory {
    static let shared = TrackersFactory()
    
    var trackers: [Tracker] {
        return [Tracker(color: 1,
                       title: "Тестовый трекер",
                       icon: 1,
                       isDoneAt: [Date()])]
    }
    
    private init() {}
}
