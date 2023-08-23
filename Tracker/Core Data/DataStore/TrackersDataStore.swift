//
//  TrackersStore.swift
//  Tracker
//
//  Created by Александр Поляков on 19.08.2023.
//
import CoreData

protocol TrackersDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(_ record: Tracker, categoryId: UUID) throws
    func delete(_ record: NSManagedObject) throws
}
