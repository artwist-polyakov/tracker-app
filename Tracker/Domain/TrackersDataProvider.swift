import Foundation
import CoreData

// Эта структура будет использоваться для уведомления о любых изменениях в данных.
struct TrackersDataUpdate {
    let section: Int
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
}


// Протокол для уведомления об изменениях.
protocol TrackersDataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackersDataUpdate)
    func reloadData()
    func reloadItems(at indexPaths: [IndexPath])
}

protocol TrackersDataProviderProtocol {
    
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> TrackersRecord?
    func addCategory(_ category: TrackerCategory) throws
    func addTracker(_ tracker: Tracker, categoryId: UUID, categoryTitle: String) throws
    func interactWith(_ trackerId: UUID, _ date: SimpleDate, indexPath: IndexPath) throws
    func deleteObject(at indexPath: IndexPath) throws
    func setDate (date: SimpleDate)
    func setQuery (query: String)
    func categoryTitle(for categoryId: UUID) -> String?
    func giveMeAnyCategory() -> TrackerCategory?
    func clearAllCoreData()
    func giveMeAllCategories() -> [TrackerCategory]
    func deleteCategory(category: TrackerCategory)
    func editCategory(category: TrackerCategory)
    func giveMeCategoryById(id: UUID) -> TrackerCategory?
}

final class TrackersDataProvider: NSObject {
    
    enum TrackersDataProviderError: Error {
        case failedToInitializeContext
    }
    private var currentSection: Int?
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
    
    private var previousSectionCount: Int? = nil
    private var shouldReloadData: Bool = false
    
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
                                        NSSortDescriptor(key:"trackerToCategory.creationDate", ascending: false),
                                        NSSortDescriptor(key:"trackerToCategory.id", ascending: false)]
        
        
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
        print("ОШИБКА previousSectionCount = \(previousSectionCount)")
        print("ОШИБКА numberOfSections = \(numberOfSections)")
        if previousSectionCount != numberOfSections {
            print("ОШИБКА: я в ветке удаления секций")
            shouldReloadData = true
        }
        
        if shouldReloadData {
            print("ОШИБКА: перезагружаю все данные")
            delegate?.reloadData()
        } else {
            print("ОШИБКА: выполняю батчапдейт")
            guard let currentSection = currentSection else {return}
            delegate?.didUpdate(TrackersDataUpdate(
                section: currentSection,
                insertedIndexes: insertedIndexes ?? IndexSet(),
                deletedIndexes: deletedIndexes ?? IndexSet(),
                updatedIndexes: updatedIndexes ?? IndexSet()
            )
            )
        }
        shouldReloadData = false
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
                currentSection = indexPath.section
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
                currentSection = indexPath.section
            }
        default:
            break
        }
    }
    
    
    private func giveCategoriesPredicate() -> NSPredicate {
        if typedText.isEmpty {
            return NSPredicate(format: "(ANY categoryToTrackers.shedule CONTAINS %@) OR (ANY categoryToTrackers.shedule == '')",
                               String(selectedDate.weekDayNum))
        } else {
            return NSPredicate(format: "((ANY categoryToTrackers.shedule CONTAINS %@) OR (ANY categoryToTrackers.shedule == '')) AND ANY categoryToTrackers.title CONTAINS[cd] %@",
                               String(selectedDate.weekDayNum), typedText)
        }
    }
    
    
    private func giveTrackersPredicate() -> NSPredicate {
        if typedText.isEmpty {
            return NSPredicate(format: "(%K CONTAINS %@) OR (%K == '')",
                               #keyPath(TrackersCoreData.shedule), String(selectedDate.weekDayNum),
                               #keyPath(TrackersCoreData.shedule))
        } else {
            return NSPredicate(format: "((%K CONTAINS %@) OR (%K == '')) AND (%K CONTAINS[cd] %@)",
                               #keyPath(TrackersCoreData.shedule), String(selectedDate.weekDayNum),
                               #keyPath(TrackersCoreData.shedule),
                               #keyPath(TrackersCoreData.title), typedText)
        }
    }
    
    
    private func reloadData() {
        previousSectionCount = numberOfSections
        categoriesFetchedResultsController.fetchRequest.predicate = giveCategoriesPredicate()
        trackersFetchedResultsController.fetchRequest.predicate = giveTrackersPredicate()
        do {
            try categoriesFetchedResultsController.performFetch()
        } catch let error as NSError  {
            print("Ошибка при получении categoriesFetchedResultsController: \(error)")
        }
        do {
            try trackersFetchedResultsController.performFetch()
        } catch let error as NSError  {
            print("Ошибка при получении trackersFetchedResultsController: \(error)")
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
        let result = trackersFetchedResultsController.sections?.count ?? .zero
        if let prev = previousSectionCount {
            if prev != result {
                previousSectionCount = result
                shouldReloadData = true
            }
        } else {
            previousSectionCount = result
        }
        return result
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        let result = trackersFetchedResultsController.sections?[section].numberOfObjects ?? .zero
        return result
    }
    
    func object(at indexPath: IndexPath) -> TrackersRecord? {
        let coreDataObject = trackersFetchedResultsController.object(at: indexPath)
        guard let id = coreDataObject.id else {return nil}
        let isDoneAt = trackersDataStore.hasExecutionForDate(for: id, date: selectedDate)
        let daysGone = trackersDataStore.numberOfExecutions(for: id)
        return TrackersRecordImpl(from: coreDataObject, daysDone: daysGone, isChecked: isDoneAt)
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        try categoriesDataStore.add(category)
    }
    
    func giveMeAnyCategory() -> TrackerCategory?  {
        guard let firstCategory = categoriesFetchedResultsController.fetchedObjects?.first,
              let id = firstCategory.id,
              let title = firstCategory.title
        else {
            return nil
        }
        return TrackerCategory(id: id, categoryTitle: title)
    }
    
    func giveMeCategoryById(id: UUID) -> TrackerCategory?  {
        let fetchRequest = NSFetchRequest<CategoriesCoreData>(entityName: "CategoriesCoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        fetchRequest.fetchLimit = 1
        do {
            let categories = try context.fetch(fetchRequest)
            guard let category = categories.first,
                  let id = category.id,
                  let title = category.title
            else {
                return nil
            }
            return TrackerCategory(id: id, categoryTitle: title)
        } catch let error as NSError {
            print("Ошибка при получении categoriesFetchedResultsController: \(error)")
            return nil
        }
    }
    
    func addTracker(_ tracker: Tracker, categoryId: UUID, categoryTitle: String) throws {
        try trackersDataStore.add(tracker, categoryId: categoryId, categoryTitle: categoryTitle)
    }
    
    func interactWith(_ trackerId: UUID, _ date: SimpleDate, indexPath: IndexPath) throws {
        try executionsDataStore.interactWith(trackerId, date)
        delegate?.reloadItems(at: [indexPath])
    }
    
    func deleteObject(at indexPath: IndexPath) throws {
        let record = trackersFetchedResultsController.object(at: indexPath)
        try? trackersDataStore.delete(record)
    }
    
    func categoryTitle(for categoryId: UUID) -> String? {
        let fetchRequest = NSFetchRequest<CategoriesCoreData>(entityName: "CategoriesCoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@", categoryId as NSUUID)
        fetchRequest.fetchLimit = 1
        do {
            let categories = try context.fetch(fetchRequest)
            return categories.first?.title
        } catch let error as NSError {
            print("Ошибка при извлечении категории: \(error)")
            return nil
        }
    }
    
    func clearAllCoreData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CategoriesCoreData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            context.reset()
            delegate?.reloadData()
        } catch let error as NSError {
            print("Ошибка при удалении CategoriesCoreData: \(error.localizedDescription)")
        }
    }
    
    func giveMeAllCategories() -> [TrackerCategory] {
        let fetchRequest = NSFetchRequest<CategoriesCoreData>(entityName: "CategoriesCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        do {
            let categoriesCoreData = try context.fetch(fetchRequest)
            
            return categoriesCoreData.compactMap { coreDataCategory in
                guard let id = coreDataCategory.id, let title = coreDataCategory.title else { return nil }
                return TrackerCategory(id: id, categoryTitle: title)
            }
            
        } catch let error as NSError {
            print("Ошибка при извлечении всех категорий: \(error)")
            return []
        }
    }
    
    func deleteCategory(category: TrackerCategory) {
        let fetchRequest = NSFetchRequest<CategoriesCoreData>(entityName: "CategoriesCoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@", category.id as NSUUID)
        fetchRequest.fetchLimit = 1

        do {
            let fetchedCategories = try context.fetch(fetchRequest)
            if let categoryToDelete = fetchedCategories.first {
                context.delete(categoryToDelete)
                try context.save()
                delegate?.reloadData()
            }
        } catch let error as NSError {
            print("Ошибка при удалении категории: \(error.localizedDescription)")
        }
    }
    
    func editCategory(category: TrackerCategory) {
        let fetchRequest = NSFetchRequest<CategoriesCoreData>(entityName: "CategoriesCoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@", category.id as NSUUID)
        fetchRequest.fetchLimit = 1
        do {
            let fetchedCategories = try context.fetch(fetchRequest)
            if let categoryToEdit = fetchedCategories.first {
                categoryToEdit.title = category.categoryTitle
                try context.save()
                delegate?.reloadData()
            }
        } catch let error as NSError {
            print("Ошибка при редактировании категории: \(error.localizedDescription)")
        }
    }
}
