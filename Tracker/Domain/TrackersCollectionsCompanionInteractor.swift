//
//  TrackersCollectionsCompanionInteractor.swift
//  Tracker
//
//  Created by Александр Поляков on 23.08.2023.
//

import Foundation
final class TrackersCollectionsCompanionInteractor {
    static let shared = TrackersCollectionsCompanionInteractor()
    let companion: TrackersCollectionsCompanion? = nil
    private init() {}
    func addTracker(tracker:Tracker, categoryId: UUID) {
        companion?.addTracker(tracker: tracker, categoryId: categoryId)
    }
}
