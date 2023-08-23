//
//  DataStore.swift
//  Tracker
//
//  Created by Александр Поляков on 22.08.2023.
//

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
        } catch {
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
        print("Пытаюсь добавить трекер")
        try performSync { context in
            Result {
                // Проверяем, существует ли уже категория с указанным categoryId
                let fetchRequest = NSFetchRequest<CategoriesCoreData>(entityName: "CategoriesCoreData")
                fetchRequest.predicate = NSPredicate(format: "id == %@", categoryId as CVarArg)
                let existingCategories = try context.fetch(fetchRequest)
                
                var finalCategoryId: UUID = categoryId
                
                // Если категория не существует, создадим новую
                if existingCategories.isEmpty {
                    let newCategory = CategoriesCoreData(context: context)
                    newCategory.title = categoryTitle
                    newCategory.creationDate = Date()
                    if let newCategoryId = newCategory.id {
                        finalCategoryId = newCategoryId
                    }
                }
                
                let trackersCoreData = TrackersCoreData(context: context)
                trackersCoreData.title = record.title
                trackersCoreData.categoryId = finalCategoryId
                trackersCoreData.creationDate = Date()
                trackersCoreData.icon = Int16(record.icon)
                trackersCoreData.shedule = record.isPlannedFor
                trackersCoreData.color = Int16(record.color)
                print("Результат добавления")
                print(trackersCoreData)
                try context.save()
            }
        }
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
                try context.save()
            }
        }
    }
}

extension DataStore: ExecutionsDataStore {
    func interactWith(_ record: Execution) throws {
        print("Attach/Detach")
    }
    
    func attachExecution(trackerId: UUID, date: Date) {
        
    }
    
    func detachExecution(trackerId: UUID, date: Date) {
        
    }
    
    
}
