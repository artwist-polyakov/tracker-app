//
//  TrackersDataStore.swift
//  Tracker
//
//  Created by Александр Поляков on 19.08.2023.
//

import Foundation
import CoreData

public final class TrackersDataStore: NSObject {
    public static let shared = TrackersDataStore()
    private override init () {}
    
    private let appdelegate: AppDelegate = AppDelegate()
    private var context: NSManagedObjectContext {
        appdelegate.persistentContainer.viewContext
    }
    
    
    // MARK: - ADD CATEGORY
    func addTrackerCategory (_ title: String ) {
        let trackerCategory = Categories(context: self.context)
        trackerCategory.category_name = title
        trackerCategory.creation_date = SimpleDate(date: Date()).date
        self.appdelegate.saveContext()
    }
    
    // MARK: - ADD TRACKER
    func addTracker(title: String,
                    color: Int,
                    icon: Int,
                    planedFor: String,
                    categoryId: UUID
    ) {
        let tracker = Trackers(context: self.context)
        tracker.category_id = categoryId
        tracker.tracker_title = title
        tracker.tracker_color = Int16(color)
        tracker.tracker_emoji = Int16(icon)
        tracker.shedule = planedFor
        tracker.creation_date = SimpleDate(date: Date()).date
        appdelegate.saveContext()
    }
    
    private func attachExecution(toDate date: Date, trackerId: UUID) {
        let newExecution = Executions(context: context)
        newExecution.date = date
        newExecution.tracker_id = trackerId
        appdelegate.saveContext()
    }
    
    private func detachExecution(byObjectId objectId: NSManagedObjectID) {
        if let objectToDelete = context.object(with: objectId) as? Executions {
            context.delete(objectToDelete)
            appdelegate.saveContext()
        }
    }
    
    // MARK: - INTERACT WITH
    func interactWithExecution(date: Date, trackerId: UUID) {
        let fetchRequest: NSFetchRequest<Executions> = Executions.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(Executions.date), date as CVarArg, #keyPath(Executions.tracker_id), trackerId as CVarArg)
        do {
            let existingExecutions = try context.fetch(fetchRequest)
            if existingExecutions.isEmpty {
                attachExecution(toDate: date, trackerId: trackerId)
            } else if let objectId = existingExecutions.first?.objectID {
                detachExecution(byObjectId: objectId)
            }
        } catch {
            print("FATAL ERROR: \(error)")
        }
    }

    
    private func fetchAllObjects<T>(entityName: String) -> [T] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            return (try? context.fetch(fetchRequest) as? [T]) ?? []
        }
    }
    
    private func fetchAllObjects<T>(request: NSFetchRequest<T>) -> [T] {
        do {
            return (try? context.fetch(request) as? [T]) ?? []
        }
    }
    
    private func getObjectByID<T>(id: NSManagedObjectID) -> T? {
        let object = (try? context.existingObject(with: id) as? T) ?? nil
        return object
    }
    
    
    private func fetchTrackersSortedByCategoryFields() -> [Trackers] {
        let request = NSFetchRequest<Trackers>(entityName: "Trackers")
        
        // Сортировка сначала по дате создания категории
        let categoryDateSort = NSSortDescriptor(key: "category_id.creation_date", ascending: true)
        // Затем сортировка по UUID категории
        let categoryUUIDSort = NSSortDescriptor(key: "category_id", ascending: true)
        // По желанию, можно добавить еще сортировку по title трекера или другим полям
        let trackerCreationSort = NSSortDescriptor(key: "creation_date", ascending: true)
        
        request.sortDescriptors = [categoryDateSort, categoryUUIDSort, trackerCreationSort]
        
        return fetchAllObjects<Trackers>(request: request)
    }
    
    // MARK: - FETCH ALL CATEGORIES WITH SORT
    private func fetchCategoriesSortedByDate() -> [Categories] {
        let request = NSFetchRequest<Categories>(entityName: "Categories")
        let categoryDateSort = NSSortDescriptor(key: "creation_date", ascending: true)
        let categoryUUIDSort = NSSortDescriptor(key: "category_id", ascending: true)
        request.sortDescriptors = [categoryDateSort, categoryUUIDSort]
        do {
            return fetchAllObjects<Categories>(request: request)
        }
    }
    
    // MARK: - FETCH ALL TRACKERS IN CATEGORY
    private func fetchAllTrackersInCategory(_ categoryId: UUID) -> [Trackers] {
        let request = NSFetchRequest<Trackers>(entityName: "Trackers")
        let trackerCreationSort = NSSortDescriptor(key: "creation_date", ascending: true)
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Trackers.category_id), categoryId as CVarArg)
        request.sortDescriptors = [trackerCreationSort]
        do {
            return fetchAllObjects<Trackers>(request: request)
        }
    }
    
}
