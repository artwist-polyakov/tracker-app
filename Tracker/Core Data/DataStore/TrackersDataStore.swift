import CoreData

protocol TrackersDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(_ record: Tracker, categoryId: UUID, categoryTitle: String) throws
    func delete(_ record: NSManagedObject) throws
}
