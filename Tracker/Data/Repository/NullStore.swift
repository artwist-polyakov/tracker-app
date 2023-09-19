import CoreData

final class NullStore {}

extension NullStore: TrackersDataStore {
    func haveStats() -> Bool {
        return false
    }
    
    func edit(_ record: Tracker) throws {
    }
    
    func chageCategory(for trackerId: UUID, to category: CategoriesCoreData) throws {
    }
    
    var managedObjectContext: NSManagedObjectContext? { nil }
    func add(_ record: Tracker, categoryId: UUID, categoryTitle: String) throws {}
    
    func delete(_ record: NSManagedObject) throws {}
    func numberOfExecutions(for trackerId: UUID) -> Int {0}
    func hasExecutionForDate(for trackerId: UUID, date: SimpleDate) -> Bool {false}
}

extension NullStore: CategoriesDataStore {
    func giveMeCategory(with id: UUID) throws -> CategoriesCoreData? {
        return nil
    }
    
    func add(_ record: TrackerCategory, _ isAutomatic: Bool) throws {}
}

extension NullStore: ExecutionsDataStore {
    func howManyCompletedTrackers() -> Int {
        return 0
    }
    
    func interactWith(_ record: UUID, _ date: SimpleDate) throws {}
}

