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
}

protocol TrackersDataProviderProtocol {
    
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> TrackersRecord?
    func addCategory(_ category: TrackerCategory) throws
    func addTracker(_ tracker: Tracker, categoryId: UUID, categoryTitle: String) throws
    func interactWith(_ trackerId: UUID, _ date: SimpleDate) throws
    func deleteObject(at indexPath: IndexPath) throws
    func setDate (date: SimpleDate)
    func setQuery (query: String)
    func categoryTitle(for categoryId: UUID) -> String?
    func giveMeAnyCategory() -> TrackerCategory?
    func clearAllCoreData()
}

final class TrackersDataProvider: NSObject {
    
    enum TrackersDataProviderError: Error {
        case failedToInitializeContext
    }
    private var currentSection: Int?
    var selectedDate: SimpleDate = SimpleDate(date: Date()) {
        didSet {
            print("Меняю дату в DidSet")
            reloadData()
        }
    }
    var typedText: String = "" {
        didSet {
            reloadData()
        }
    }
    
    
    private var previousSectionCount: Int = 0
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
        super.init()
        print("Всего объектов в trackersFetchedResultsController: \(trackersFetchedResultsController.fetchedObjects?.count ?? 0)")
        
        for section in 0..<numberOfSections {
            print("Объекты в секции \(section): \(numberOfRowsInSection(section))")
            if let firstTrackerInSection = trackersFetchedResultsController.object(at: IndexPath(item: 0, section: section)) as? TrackersRecord {
                print("Первый трекер в секции \(section): \(firstTrackerInSection)")
            } else {
                print("Не удалось получить первый трекер для секции \(section)")
            }
        }
        
    }
    
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackersDataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if previousSectionCount != numberOfSections {
            shouldReloadData = true
        }
        
        if shouldReloadData {
            delegate?.reloadData()
        } else {
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
            return NSPredicate(format: "(ANY category_to_trackers.shedule CONTAINS %@) OR (ANY category_to_trackers.shedule == '')",
                               String(selectedDate.weekDayNum))
        } else {
            return NSPredicate(format: "((ANY category_to_trackers.shedule CONTAINS %@) OR (ANY category_to_trackers.shedule == '')) AND ANY category_to_trackers.title CONTAINS[cd] %@",
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
        print("Метод reloadData вызван.")
        previousSectionCount = numberOfSections
        categoriesFetchedResultsController.fetchRequest.predicate = giveCategoriesPredicate()
        trackersFetchedResultsController.fetchRequest.predicate = giveTrackersPredicate()
        do {
            print(" try categoriesFetchedResultsController")
            try categoriesFetchedResultsController.performFetch()
        } catch let error as NSError  {
            print("Error performing fetch: \(error)")
        }
        do {
            print(" try trackersFetchedResultsController")
            try trackersFetchedResultsController.performFetch()
        } catch let error as NSError  {
            print("Error performing fetch: \(error)")
        }
        print("Метод reloadData завершен")
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
        let result = trackersFetchedResultsController.sections?.count ?? 0
        let totalObjects = trackersFetchedResultsController.fetchedObjects?.count ?? 0
        print("Общее количество объектов: \(totalObjects)")
        print("Метод numberOfSections вызван. Резульатат \(result)")
        return result
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        print("Метод numberOfRowsInSection вызван для секции \(section).")
        let result = trackersFetchedResultsController.sections?[section].numberOfObjects ?? 0
        print("число элементов \(result)")
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
    
    func addTracker(_ tracker: Tracker, categoryId: UUID, categoryTitle: String) throws {
        print("Добавление трекера в провайдере")
        try trackersDataStore.add(tracker, categoryId: categoryId, categoryTitle: categoryTitle)
    }
    
    func interactWith(_ trackerId: UUID, _ date: SimpleDate) throws {
        try executionsDataStore.interactWith(trackerId, date)
    }
    
    func deleteObject(at indexPath: IndexPath) throws {
        let record = trackersFetchedResultsController.object(at: indexPath)
        try? trackersDataStore.delete(record)
    }
    
    func categoryTitle(for categoryId: UUID) -> String? {
        let fetchRequest = NSFetchRequest<CategoriesCoreData>(entityName: "CategoriesCoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@", categoryId as NSUUID)
        fetchRequest.fetchLimit = 1
        print("Запрос на категорию вызван")
        do {
            let categories = try context.fetch(fetchRequest)
            print(categories)
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
            print("Error deleting CategoriesCoreData: \(error.localizedDescription)")
        }
    }
    
    
    
    
}
