//
//  TrackersCollectionsCompanionInteractor.swift
//  Tracker
//
//  Created by Александр Поляков on 23.08.2023.
//

import Foundation
final class TrackersCollectionsCompanionInteractor {
    static let shared = TrackersCollectionsCompanionInteractor()
    var companion: TrackersCollectionsCompanion? = nil
    private init() {}
    
    func addTracker(tracker:Tracker, categoryId: UUID, categoryTitle: String) {
        print("Добавление трекера в интеракторе")
        companion?.addTracker(tracker: tracker, categoryId: categoryId, categoryTitle: categoryTitle)
    }
    
    func giveMeAnyCategory() -> TrackerCategory? {
        return companion?.giveMeAnyTrackercategory()
    }
}
