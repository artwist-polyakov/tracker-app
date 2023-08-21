//
//  TrackersDataStore.swift
//  Tracker
//
//  Created by Александр Поляков on 21.08.2023.
//

import CoreData

protocol TrackersDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(_ record: TrackersRecord) throws
    func delete(_ record: NSManagedObject) throws
}
