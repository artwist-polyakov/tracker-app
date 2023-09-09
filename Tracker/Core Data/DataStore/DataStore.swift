import Foundation
import CoreData

// MARK: - DataStore
final class DataStore {
    
    private let modelName = "Trackers"
    private let storeURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("data-store.sqlite")
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    init() throws {
        guard let modelUrl = Bundle(for: DataStore.self).url(forResource: modelName, withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelUrl) else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch let error as NSError {
            print("Произошла ошибка при инициализации dataStore: \(error.localizedDescription)")
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
    
    private func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
}

// MARK: - TrackersDataStore
extension DataStore: TrackersDataStore {
    var managedObjectContext: NSManagedObjectContext? {
        context
    }
    
    func add(_ record: Tracker, categoryId: UUID, categoryTitle: String) throws {
        try performSync { context in
            Result {
                let fetchRequest = NSFetchRequest<CategoriesCoreData>(entityName: "CategoriesCoreData")
                fetchRequest.predicate = NSPredicate(format: "id == %@", categoryId as NSUUID)
                let existingCategories = try context.fetch(fetchRequest)
                
                var finalCategory: CategoriesCoreData
                if let firstCategory = existingCategories.first {
                    finalCategory = firstCategory
                } else {
                    let newCategory = CategoriesCoreData(context: context)
                    newCategory.id = UUID()
                    newCategory.title = categoryTitle
                    newCategory.creationDate = Date()
                    finalCategory = newCategory
                }
                
                let trackersCoreData = TrackersCoreData(context: context)
                trackersCoreData.title = record.title
                trackersCoreData.categoryId = finalCategory.id
                trackersCoreData.creationDate = Date()
                trackersCoreData.icon = Int16(record.icon)
                trackersCoreData.shedule = record.isPlannedFor
                trackersCoreData.color = Int16(record.color)
                trackersCoreData.id = UUID()
                
                trackersCoreData.trackerToCategory = finalCategory
                do {
                    try context.save()
                } catch let error as NSError {
                    print("ОШИБКА Ошибка при сохранении контекста: \(error)")
                }
            }
        }
    }
    
    func numberOfExecutions(for trackerId: UUID) -> Int {
        let fetchRequest = NSFetchRequest<ExecutionsCoreData>(entityName: "ExecutionsCoreData")
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@", trackerId as NSUUID)
        let count = try? context.count(for: fetchRequest)
        return count ?? .zero
    }
    
    func hasExecutionForDate(for trackerId: UUID, date: SimpleDate) -> Bool {
        let fetchRequest = NSFetchRequest<ExecutionsCoreData>(entityName: "ExecutionsCoreData")
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@ AND date == %@", trackerId as NSUUID, date.date as NSDate)
        let count = try? context.count(for: fetchRequest)
        return count ?? .zero > .zero
    }
    
    
    
    
    func delete(_ record: NSManagedObject) throws {
        try performSync { context in
            Result {
                context.delete(record)
                try context.save()
            }
        }
    }
}

extension DataStore: CategoriesDataStore {
    func add(_ record: TrackerCategory) throws {
        try performSync { context in
            Result {
                let categoriesCoreData = CategoriesCoreData(context: context)
                categoriesCoreData.title = record.categoryTitle
                categoriesCoreData.creationDate = Date()
                categoriesCoreData.id = record.id
                try context.save()
            }
        }
    }
}

extension DataStore: ExecutionsDataStore {
    func interactWith(_ record: UUID, _ date: SimpleDate) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ExecutionsCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(ExecutionsCoreData.date), date.date as NSDate, #keyPath(ExecutionsCoreData.trackerId), record as NSUUID)
        fetchRequest.resultType = .managedObjectIDResultType
        
        do {
            let existingExecutions = try context.fetch(fetchRequest) as! [NSManagedObjectID]
            if existingExecutions.isEmpty {
                attachExecution(trackerId: record, date: date.date)
            } else {
                if let objectId = existingExecutions.first {
                    detachExecution(byObjectId: objectId)
                }
            }
        } catch {
            print("ФАТАЛЬНАЯ ОШИБКА: \(error)")
            throw error
        }
    }
    
    private func attachExecution(trackerId: UUID, date: Date) {
        let newExecution = ExecutionsCoreData(context: context)
        newExecution.date = date
        newExecution.trackerId = trackerId
        
        do {
            try context.save()
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ExecutionsCoreData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(ExecutionsCoreData.date), date as NSDate, #keyPath(ExecutionsCoreData.trackerId), trackerId as NSUUID)
        } catch let error as NSError {
            print("Ошибка при сохранении выполнения: \(error.localizedDescription)")
        }
    }
    
    private func detachExecution(byObjectId objectId: NSManagedObjectID) {
        if let objectToDelete = context.object(with: objectId) as? ExecutionsCoreData {
            context.delete(objectToDelete)
            do {
                try context.save()
            } catch let error as NSError {
                print("Ошибка при удалении выполнения: \(error.localizedDescription)")
            }
        }
    }
    
    
}
