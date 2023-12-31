import Foundation
final class TrackersCollectionsCompanionInteractor {
    static let shared = TrackersCollectionsCompanionInteractor()
    weak var companion: TrackersCollectionsCompanion? = nil
    private init() {}
    
    func addTracker(tracker:Tracker, categoryId: UUID, categoryTitle: String) {
        companion?.addTracker(tracker: tracker, categoryId: categoryId, categoryTitle: categoryTitle)
    }
    
    func giveMeCategoryById(id: UUID) -> TrackerCategory? {
        return companion?.giveMeCategoryById(id: id)
    }
    
    func clearAllCoreData() {
        companion?.clearAllCoreData()
    }
    
    func giveMeAllCategories(filterType: CategoryFilterType) -> [TrackerCategory]? {
        return companion?.giveMeAllCategories(filterType: filterType)
    }
    
    func addCategory(name: String) {
        let category = TrackerCategory(id: UUID(), categoryTitle: name)

        companion?.addCategory(category: category)
    }
    
    func removeCategory(category: TrackerCategory) {
        companion?.deleteCategory(category: category)
    }
    
    func editCategory(category: TrackerCategory, newName: String) {

        let newCategory = TrackerCategory(id: category.id, categoryTitle: newName)
        companion?.editCategory(category: newCategory)
    }
    
    func editTracker(saveVersion newTracker: Tracker) {
        companion?.editTracker(newTracker)
    }
    
    
}
