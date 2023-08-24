import CoreData

final class NullStore {}

extension NullStore: TrackersDataStore {   
    var managedObjectContext: NSManagedObjectContext? { nil }
    func add(_ record: Tracker, categoryId: UUID, categoryTitle: String) throws {}
    func delete(_ record: NSManagedObject) throws {}
}

extension NullStore: CategoriesDataStore {
    func add(_ record: TrackerCategory) throws {}
}

extension NullStore: ExecutionsDataStore {
    func interactWith(_ record: Execution) throws {}
}

