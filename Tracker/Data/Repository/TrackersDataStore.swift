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
    
    func addTrackerCategory (_ title: String ) {
        let trackerCategory = Categories(context: self.context)
        trackerCategory.category_name = title
        trackerCategory.creation_date = SimpleDate(date: Date()).date
        self.appdelegate.saveContext()
    }
    
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
    
    func addExecution(tracker_id: UUID) {
        let execution = Executions(context: self.context)
        execution.date = SimpleDate(date: Date()).date
        execution.tracker_id = tracker_id
        appdelegate.saveContext()
    }
    
    func fetchAllObjects<T>(entityName: String) -> [T] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            return (try? context.fetch(fetchRequest) as? [T]) ?? []
        }
    }
    
    func getObjectByID<T>(id: NSManagedObjectID) -> T? {
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
        
        do {
            return (try? context.fetch(request) as? [Trackers]) ?? []
        }
    }
    
    private func fetchCategoriesSortedByDate() -> [Categories] {
        let request = NSFetchRequest<Categories>(entityName: "Categories")
        let categoryDateSort = NSSortDescriptor(key: "creation_date", ascending: true)
        let categoryUUIDSort = NSSortDescriptor(key: "category_id", ascending: true)
        request.sortDescriptors = [categoryDateSort, categoryUUIDSort]
        do {
            return (try? context.fetch(request) as? [Categories]) ?? []
        }
        
    }
    
}
