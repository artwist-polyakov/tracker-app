//
//  TrackersStorageProtocol.swift
//  Tracker
//
//  Created by Александр Поляков on 04.08.2023.
//

import Foundation
protocol TrackersStorageProtocol {
    var trackerTitle: String {get set}
    var trackers: [Tracker]? { get set }
    func addDay(to toPosition: Int, day date: SimpleDate, _ completion: ()->())
    func removeDay(to toPosition: Int, day date: SimpleDate, _ completion: ()->())
}
