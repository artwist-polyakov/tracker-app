//
//  CategoriesDataStore.swift
//  Tracker
//
//  Created by Александр Поляков on 21.08.2023.
//

import CoreData

protocol CategoriesDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(_ record: TrackerCategory) throws
    func delete(_ record: NSManagedObject) throws
}
