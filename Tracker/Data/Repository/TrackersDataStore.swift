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
        let trackerCategory = CategoriesCoreData(context: self.context)
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
        let tracker = TrackersCoreData(context: self.context)
        tracker.category_id = categoryId
        tracker.tracker_title = title
        tracker.tracker_color = Int16(color)
        tracker.tracker_emoji = Int16(icon)
        tracker.shedule = planedFor
        tracker.creation_date = SimpleDate(date: Date()).date
        appdelegate.saveContext()
    }
    
    private func attachExecution(toDate date: Date, trackerId: UUID) {
        let newExecution = ExecutionsCoreData(context: context)
        newExecution.date = date
        newExecution.tracker_id = trackerId
        appdelegate.saveContext()
    }
    
    private func detachExecution(byObjectId objectId: NSManagedObjectID) {
        if let objectToDelete = context.object(with: objectId) as? ExecutionsCoreData {
            context.delete(objectToDelete)
            appdelegate.saveContext()
        }
    }
    
    // MARK: - INTERACT WITH
    func interactWithExecution(date: Date, trackerId: UUID) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ExecutionsCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(ExecutionsCoreData.date), date as CVarArg, #keyPath(ExecutionsCoreData.tracker_id), trackerId as CVarArg)
        fetchRequest.resultType = .managedObjectIDResultType
        do {
            let existingExecutions = try context.fetch(fetchRequest) as! [NSManagedObjectID]
            if existingExecutions.isEmpty {
                attachExecution(toDate: date, trackerId: trackerId)
            } else {
                let objectId = existingExecutions.first!
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
    
    // MARK: ALL TRACKERS SORTED
    private func fetchTrackersSortedByCategoryFields() -> [TrackersCoreData] {
        let request = NSFetchRequest<TrackersCoreData>(entityName: "TrackersCoreData")
        
        // Сортировка сначала по дате создания категории
        let categoryDateSort = NSSortDescriptor(key: "category_id.creation_date", ascending: true)
        // Затем сортировка по UUID категории
        let categoryUUIDSort = NSSortDescriptor(key: "category_id", ascending: true)
        // По желанию, можно добавить еще сортировку по title трекера или другим полям
        let trackerCreationSort = NSSortDescriptor(key: "creation_date", ascending: true)
        
        request.sortDescriptors = [categoryDateSort, categoryUUIDSort, trackerCreationSort]
        
        return fetchAllObjects<TrackersCoreData>(request: request)
    }
    
    private func fetchCategoriesSortedByDate(plannedDay substring: String, searchQuery: String) -> [CategoriesCoreData] {
        let request = NSFetchRequest<CategoriesCoreData>(entityName: "CategoriesCoreData")
        let categoryDateSort = NSSortDescriptor(key: "creation_date", ascending: true)
        let categoryUUIDSort = NSSortDescriptor(key: "category_id", ascending: true)

        // Предикат для отбора категорий, основываясь на их трекерах
        request.predicate = NSPredicate(format: "ANY category_to_trackers.shedule CONTAINS %@ AND ANY category_to_trackers.title CONTAINS[cd] %@",
                                        substring, searchQuery)

        request.sortDescriptors = [categoryDateSort, categoryUUIDSort]

        do {
            return fetchAllObjects<CategoriesCoreData>(request: request)
        }
    }

    
    // MARK: - FETCH ALL TRACKERS IN CATEGORY
    private func fetchAllTrackersInCategory(_ categoryId: UUID, plannedDay substring: String, searchQuery: String) -> [TrackersCoreData] {
        let request = NSFetchRequest<TrackersCoreData>(entityName: "TrackersCoreData")
        let trackerCreationSort = NSSortDescriptor(key: "creation_date", ascending: true)
        
        // Предикат для поиска трекеров, которые:
        // 1) Принадлежат определенной категории
        // 2) Содержат подстроку в поле shedule или имеют пустое значение shedule
        // 3) Содержат searchQuery в поле title
        request.predicate = NSPredicate(format: "(%K == %@) AND ((%K CONTAINS %@) OR (%K == '')) AND (%K CONTAINS[cd] %@)",
                                        #keyPath(TrackersCoreData.category_id), categoryId as CVarArg,
                                        #keyPath(TrackersCoreData.shedule), substring,
                                        #keyPath(TrackersCoreData.shedule),
                                        #keyPath(TrackersCoreData.tracker_title), searchQuery)
        
        request.sortDescriptors = [trackerCreationSort]
        return fetchAllObjects<TrackersCoreData>(request: request)
    }


    
    // MARK: - COUNT TRACKERS IN CATEGORY
    private func countAllTrackersInCategory(_ categoryId: UUID, plannedDay substring: String, searchQuery: String) -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackersCoreData")
        
        // Предикат для поиска трекеров, которые:
        // 1) Принадлежат определенной категории
        // 2) Содержат подстроку в поле shedule или имеют пустое значение shedule
        // 3) Содержат searchQuery в поле title
        request.predicate = NSPredicate(format: "(%K == %@) AND ((%K CONTAINS %@) OR (%K == '')) AND (%K CONTAINS[cd] %@)",
                                        #keyPath(TrackersCoreData.category_id), categoryId as CVarArg,
                                        #keyPath(TrackersCoreData.shedule), substring,
                                        #keyPath(TrackersCoreData.shedule),
                                        #keyPath(TrackersCoreData.tracker_title), searchQuery)
        
        request.resultType = .countResultType

        let count = (try? context.count(for: request)) ?? 0
        return count
    }
    
    // MARK: - IS TRACKER DONE AT DATE
    private func isTrackerDoneAtDate(_ trackerId: UUID, _ date: Date) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ExecutionsCoreData")
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        #keyPath(ExecutionsCoreData.date), date as CVarArg,
                                        #keyPath(ExecutionsCoreData.tracker_id), trackerId as CVarArg)
        request.resultType = .countResultType
        let count = (try? context.count(for: request)) ?? 0
        return count > 0
    }
    
    // MARK: - HOW MANY EXECUTIONS TRACKER HAS
    private func isTrackerDoneAtDate(_ trackerId: UUID) -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ExecutionsCoreData")
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(ExecutionsCoreData.tracker_id), trackerId as CVarArg)
        request.resultType = .countResultType
        let count = (try? context.count(for: request)) ?? 0
        return count
    }
}
