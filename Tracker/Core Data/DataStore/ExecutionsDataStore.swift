//
//  ExecutionsDataStore.swift
//  Tracker
//
//  Created by Александр Поляков on 21.08.2023.
//

import CoreData

protocol ExecutionsDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func interactWith(_ record: Execution) throws
}
