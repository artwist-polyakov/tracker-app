import CoreData

protocol TrackersDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(_ record: Tracker, categoryId: UUID, categoryTitle: String) throws
    func edit(_ record: Tracker) throws
    func delete(_ record: NSManagedObject) throws
    func numberOfExecutions(for trackerId: UUID) -> Int
    func hasExecutionForDate(for trackerId: UUID, date: SimpleDate) -> Bool
    func chageCategory(for trackerId: UUID, to category: CategoriesCoreData) throws
    func haveStats() -> Bool
}
