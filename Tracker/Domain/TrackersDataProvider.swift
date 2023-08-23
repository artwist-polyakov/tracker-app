//
//  TrackersDataProvider.swift
//  Tracker
//
//  Created by Александр Поляков on 21.08.2023.
//

import Foundation
import CoreData

// Эта структура будет использоваться для уведомления о любых изменениях в данных.
struct TrackersDataUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
}

// Протокол для уведомления об изменениях.
protocol TrackersDataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackersDataUpdate)
}

protocol TrackersDataProviderProtocol {
    
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> TrackersRecord?
    func addCategory(_ category: TrackerCategory) throws
    func addTracker(_ tracker: Tracker, categoryId: UUID) throws
    func addExecution(_ execution: Execution) throws
    func deleteObject(at indexPath: IndexPath) throws
    func setDate (date: SimpleDate)
    func setQuery (query: String)
}

final class TrackersDataProvider: NSObject {
    
    enum TrackersDataProviderError: Error {
        case failedToInitializeContext
    }
    
    var selectedDate: SimpleDate = SimpleDate(date: Date()) {
        didSet {
            reloadData()
        }
    }
    var typedText: String = "" {
        didSet {
            reloadData()
        }
    }
    
    weak var delegate: TrackersDataProviderDelegate?
    
    private let context: NSManagedObjectContext
    private let trackersDataStore: TrackersDataStore
    private let categoriesDataStore: CategoriesDataStore
    private let executionsDataStore: ExecutionsDataStore

    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    
    private lazy var categoriesFetchedResultsController: NSFetchedResultsController<CategoriesCoreData> = {
        let fetchRequest = NSFetchRequest<CategoriesCoreData>(entityName: "CategoriesCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        fetchRequest.predicate = giveCategoriesPredicate()
        
        let fetchedResultsController = NSFetchedResultsController(
                                        fetchRequest: fetchRequest,
                                        managedObjectContext: context,
                                        sectionNameKeyPath: "id",
                                        cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    private lazy var trackersFetchedResultsController:  NSFetchedResultsController<TrackersCoreData> = {
        let fetchRequest = NSFetchRequest<TrackersCoreData>(entityName: "TrackersCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true),
            NSSortDescriptor(key:"tracker_to_category.creationDate", ascending: false),
            NSSortDescriptor(key:"tracker_to_category.id", ascending: false)]
        
        
        fetchRequest.predicate = giveTrackersPredicate()
        let fetchedResultsController = NSFetchedResultsController(
                                        fetchRequest: fetchRequest,
                                        managedObjectContext: context,
                                        sectionNameKeyPath: "categoryId",
                                        cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(trackersStore trackersDataStore: TrackersDataStore,
         categoriesStore categoriesDataStore: CategoriesDataStore,
         executionsStore executionsDataStore: ExecutionsDataStore,
         delegate: TrackersDataProviderDelegate)
        throws {
        guard let context = trackersDataStore.managedObjectContext else {
            throw TrackersDataProviderError.failedToInitializeContext
        }
        self.delegate = delegate
        self.context = context
        self.trackersDataStore = trackersDataStore
        self.categoriesDataStore = categoriesDataStore
        self.executionsDataStore = executionsDataStore
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackersDataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackersDataUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!,
                updatedIndexes: updatedIndexes!
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
    
    private func giveCategoriesPredicate() -> NSPredicate {
        let predicate = NSPredicate(format: "ANY category_to_trackers.shedule CONTAINS %@ AND ANY category_to_trackers.title CONTAINS[cd] %@",
                                    String(selectedDate.weekDayNum), typedText)
        return predicate
    }
    
    private func giveTrackersPredicate() -> NSPredicate {
        let predicate = NSPredicate(format: "(%K == %@) AND ((%K CONTAINS %@) OR (%K == '')) AND (%K CONTAINS[cd] %@)",
                                    #keyPath(TrackersCoreData.shedule), String(selectedDate.weekDayNum),
                                    #keyPath(TrackersCoreData.shedule),
                                    #keyPath(TrackersCoreData.title), typedText)
        return predicate
    }
    
    private func reloadData() {
        categoriesFetchedResultsController.fetchRequest.predicate = giveCategoriesPredicate()
        trackersFetchedResultsController.fetchRequest.predicate = giveTrackersPredicate()
        do {
            try categoriesFetchedResultsController.performFetch()
        } catch {
            print("Error performing fetch: \(error)")
        }
        do {
            try trackersFetchedResultsController.performFetch()
        } catch {
            print("Error performing fetch: \(error)")
        }
    }
}

extension TrackersDataProvider: TrackersDataProviderProtocol {
    func setDate(date: SimpleDate) {
        self.selectedDate  = date
    }
    
    func setQuery(query: String) {
        self.typedText = query
    }
    
    
    var numberOfSections: Int {
        return categoriesFetchedResultsController.sections?.count ?? 0  }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        trackersFetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackersRecord? {
        trackersFetchedResultsController.object(at: indexPath) as? any TrackersRecord
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        try categoriesDataStore.add(category)
    }
    
    func addTracker(_ tracker: Tracker, categoryId: UUID) throws {
        try trackersDataStore.add(tracker, categoryId: categoryId)
    }
    
    func addExecution(_ execution: Execution) throws {
        try executionsDataStore.interactWith(execution)
    }
    
    func deleteObject(at indexPath: IndexPath) throws {
        let record = trackersFetchedResultsController.object(at: indexPath)
        try? trackersDataStore.delete(record)
    }
    
    
}
