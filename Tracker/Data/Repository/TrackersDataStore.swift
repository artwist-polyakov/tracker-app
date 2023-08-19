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
        let trackerCategory = Category(context: self.context)
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
    
}
