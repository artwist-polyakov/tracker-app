//
//  NullStore.swift
//  Tracker
//
//  Created by Александр Поляков on 19.08.2023.
//

import CoreData

final class NullStore {}

extension NullStore: DataStore {
    var managedObjectContext: NSManagedObjectContext? { nil }
    func add(_ record: Tracker) throws {}
    func delete(_ record: NSManagedObject) throws {}
}
