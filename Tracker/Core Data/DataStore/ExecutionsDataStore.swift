import CoreData

protocol ExecutionsDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func interactWith(_ record: UUID, _ date: SimpleDate) throws
    func howManyCompletedTrackers() -> Int
    func mostLongSeries() -> Int
}
