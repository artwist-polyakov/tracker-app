import CoreData

protocol CategoriesDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(_ record: TrackerCategory) throws
    func delete(_ record: NSManagedObject) throws
}
