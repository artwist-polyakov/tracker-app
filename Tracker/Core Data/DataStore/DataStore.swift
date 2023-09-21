import Foundation
import CoreData

protocol DataStoreProtocol: TrackersDataStore, CategoriesDataStore, ExecutionsDataStore {}

// MARK: - DataStore
final class DataStore: DataStoreProtocol {
    
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
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
        } catch let error as NSError {
            print("Произошла ошибка при инициализации dataStore: \(error.localizedDescription)")
            throw StoreError.failedToLoadPersistentContainer(error)
        }
        
        
    }
    
    private func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        
        context.performAndWait {
            result = action(context)
        }
        
        if case .failure(let error) = result {
            print("Ошибка при выполнении действия в контексте: \(error.localizedDescription)")
            throw error
        }
        
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
    func haveStats() -> Bool {
        let fetchRequest: NSFetchRequest<TrackersCoreData> = TrackersCoreData.fetchRequest()
        let count = try? context.count(for: fetchRequest)
        return (count ?? .zero) > 0
    }
    
    func chageCategory(for trackerId: UUID, to category: CategoriesCoreData) throws {
        let fetchRequest = NSFetchRequest<TrackersCoreData>(entityName: "TrackersCoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as NSUUID)
        let existingTrackers = try context.fetch(fetchRequest)
        let currentContextCategory = context.object(with: category.objectID) as! CategoriesCoreData

        if let tracker = existingTrackers.first {
            tracker.trackerToCategory = currentContextCategory
            tracker.isPinned = !tracker.isPinned
            do {
                try context.save()
                
            } catch let error as NSError {
                print("Ошибка при сохранении изменений в контексте: \(error)")
                throw error
            }
        } else {
            throw NSError(domain: "DataStoreError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Tracker not found for provided ID."])
        }
    }
    
    func edit(_ tracker: Tracker) throws {
        let fetchRequest = NSFetchRequest<TrackersCoreData>(entityName: "TrackersCoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as NSUUID)
        let existingTrackers = try context.fetch(fetchRequest)
        
        if let existingTracker = existingTrackers.first {
            existingTracker.title = tracker.title
            existingTracker.icon = Int16(tracker.icon)
            existingTracker.color = Int16(tracker.color)
            existingTracker.shedule = tracker.isPlannedFor
            existingTracker.categoryId = tracker.categoryId
            if !existingTracker.isPinned {
                let categoryFetchRequest = NSFetchRequest<CategoriesCoreData>(entityName: "CategoriesCoreData")
                categoryFetchRequest.predicate = NSPredicate(format: "id == %@", tracker.categoryId as NSUUID)
                let existingCategories = try context.fetch(categoryFetchRequest)
                existingTracker.trackerToCategory = existingCategories.first
            }
            do {
                try context.save()
            } catch let error as NSError {
                print("Ошибка при сохранении изменений в контексте: \(error)")
                throw error
            }
        } else {
            throw NSError(domain: "DataStoreError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Tracker not found for provided ID."])
        }
    }
    
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
                    print("Ошибка при сохранении контекста: \(error)")
                }
            }
        }
    }
    
    func giveMeCategory(with id: UUID) throws -> CategoriesCoreData?  {
        let fetchRequest = NSFetchRequest<CategoriesCoreData>(entityName: "CategoriesCoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        let existingCategories = try context.fetch(fetchRequest)
        if let firstCategory = existingCategories.first {
            return firstCategory
        } else {
            return nil
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
                // Удаление объекта
                context.delete(record)
                
                // Сохранение изменений
                try context.save()
            }
        }
    }
}

extension DataStore: CategoriesDataStore {
    func add(_ record: TrackerCategory, _ isAutomatic: Bool) throws {
        try performSync { context in
            Result {
                let categoriesCoreData = CategoriesCoreData(context: context)
                categoriesCoreData.title = record.categoryTitle
                categoriesCoreData.creationDate = isAutomatic ? Date(timeIntervalSince1970: 0) : Date()
                categoriesCoreData.id = record.id
                categoriesCoreData.isAutomatic = isAutomatic
                try context.save()
            }
        }
    }
}

extension DataStore: ExecutionsDataStore {
    func mostLongSeries() -> Int {
        let fetchRequest = NSFetchRequest<ExecutionsCoreData>(entityName: "ExecutionsCoreData")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try controller.performFetch()
            guard let fetchedObjects = controller.fetchedObjects else {
                return 0
            }
            
            var maxSeries = 0
            var currentSeries = 0
            var previuosDate =  Date()
            if fetchedObjects.count >= 1 {
                for i in 0...fetchedObjects.count - 1 {
                    guard let date = fetchedObjects[i].date
                    else {
                        return maxSeries}
                    print(currentSeries)
                    if currentSeries > maxSeries {
                        maxSeries = currentSeries
                    }
                    print("\(previuosDate) \(date)")
                    if i != 0 && abs(Calendar.current.dateComponents([.day], from: previuosDate, to: date).day!) > 1 {
                        print("\(previuosDate) \(date)")
                        currentSeries = 0
                    } else if  i != 0 && abs(Calendar.current.dateComponents([.day], from: previuosDate, to: date).day!) == 0 {
                        currentSeries -= 1
                    }
                    currentSeries += 1
                    previuosDate = date
                }
                return maxSeries
            } else {
                return 0
            }
        } catch {
            print("Ошибка при извлечении уникальных дат: \(error)")
            return 0
        }
    }
    
    func howManyCompletedTrackers() -> Int {
        let fetchRequest = NSFetchRequest<ExecutionsCoreData>(entityName: "ExecutionsCoreData")
        let count = try? context.count(for: fetchRequest)
        return count ?? .zero
    }
    
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
        try? performSync { context in
            Result {
                let newExecution = ExecutionsCoreData(context: context)
                newExecution.date = date
                newExecution.trackerId = trackerId
                let trackerFetchRequest: NSFetchRequest<TrackersCoreData> = TrackersCoreData.fetchRequest()
                trackerFetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as NSUUID)
                if let tracker = try context.fetch(trackerFetchRequest).first {
                    newExecution.executionToTrackers = tracker
                    tracker.lastUpdate = Date()
                }
                try context.save()
            }
        }
    }

    private func detachExecution(byObjectId objectId: NSManagedObjectID) {
        try? performSync { context in
            Result {
                if let objectToDelete = context.object(with: objectId) as? ExecutionsCoreData {
                    if let relatedTracker = objectToDelete.executionToTrackers {
                        relatedTracker.lastUpdate = Date()
                        if let executionsSet = relatedTracker.value(forKey: "trackerToExecutions") as? NSMutableSet {
                            executionsSet.remove(objectToDelete)
                        }
                    }
                    context.delete(objectToDelete)
                    try context.save()
                }
            }
        }
    }
}
