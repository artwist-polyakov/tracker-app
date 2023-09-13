import CoreData

protocol CategoriesDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(_ record: TrackerCategory, _ isAutomatic: Bool) throws
    func delete(_ record: NSManagedObject) throws
    func giveMeCategory(with id: UUID) throws -> CategoriesCoreData? 
}
