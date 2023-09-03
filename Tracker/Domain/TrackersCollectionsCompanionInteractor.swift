import Foundation
final class TrackersCollectionsCompanionInteractor {
    static let shared = TrackersCollectionsCompanionInteractor()
    weak var companion: TrackersCollectionsCompanion? = nil
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
    
    func giveMeAllCategories() -> [TrackerCategory]? {
        return companion?.giveMeAllCategories()
    }
    
    func addCategory(name: String) {
        let category = TrackerCategory(id: UUID(), categoryTitle: name)
        companion?.addCategory(category: category)
    }
}
