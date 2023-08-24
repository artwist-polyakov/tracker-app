import Foundation
final class TrackersCollectionsCompanionInteractor {
    static let shared = TrackersCollectionsCompanionInteractor()
    var companion: TrackersCollectionsCompanion? = nil
    private init() {}
    
    func addTracker(tracker:Tracker, categoryId: UUID, categoryTitle: String) {
        companion?.addTracker(tracker: tracker, categoryId: categoryId, categoryTitle: categoryTitle)
    }
    
    func giveMeAnyCategory() -> TrackerCategory? {
        return companion?.giveMeAnyCategory()
    }
    
    func clearAllCoreData() {
        companion?.clearAllCoreData()
    }    
}
