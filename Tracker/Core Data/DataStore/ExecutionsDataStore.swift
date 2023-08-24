import CoreData

protocol ExecutionsDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func interactWith(_ record: Execution) throws
}
