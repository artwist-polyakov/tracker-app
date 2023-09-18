import Foundation
import CoreData

enum CategoryFilterType {
    case all
    case automatic
    case manual
}

enum TrackerPredicateType {
    case defaultPredicate
    case allTrackers
    case todayTrackers
    case completedTrackers
    case uncompletedTrackers
}

// Эта структура будет использоваться для уведомления о любых изменениях в данных.
struct TrackersDataUpdate {
    let insertedIndexes: [IndexPath]
    let deletedIndexes: [IndexPath]
    let updatedIndexes: [IndexPath]
    let movedIndexes: [(from: IndexPath, to: IndexPath)]
    let insertedSections: IndexSet
    let deletedSections: IndexSet
    let updatedSections: IndexSet
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
    func addCategory(_ category: TrackerCategory, isAutomatic:Bool) throws
    func addTracker(_ tracker: Tracker, categoryId: UUID, categoryTitle: String) throws
    func editTracker(_ tracker: Tracker) throws
    func interactWith(_ trackerId: UUID, _ date: SimpleDate, indexPath: IndexPath) throws
    func deleteObject(at indexPath: IndexPath) throws
    func setDate (date: SimpleDate)
    func setQuery (query: String)
    func categoryTitle(for categoryId: UUID) -> String?
    func giveMeAnyCategory() -> TrackerCategory?
    func clearAllCoreData()
    func giveMeAllCategories(filterType: CategoryFilterType) -> [TrackerCategory]
    func deleteCategory(category: TrackerCategory)
    func editCategory(category: TrackerCategory)
    func giveMeCategoryById(id: UUID) -> TrackerCategory?
    func checkPinnedCategory()
    func interactWithTrackerPinning(_ tracker: TrackersRecord) throws
    func categoryConnectedToTracker(trackerId: UUID) -> TrackerCategory?
    func setPredicate(predicate: TrackerPredicateType)
}

extension TrackersDataProviderProtocol {
    func giveMeAllCategories() -> [TrackerCategory] {
        return giveMeAllCategories(filterType: .manual)
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        try addCategory(category, isAutomatic: false)
    }
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
    
    var currentPredicateType: TrackerPredicateType = .defaultPredicate {
        didSet {
            print("Я провайдер данных — меняю предикат \(currentPredicateType)")
            reloadData()
            delegate?.reloadData()
            
        }
    }
    
    
    weak var delegate: TrackersDataProviderDelegate?
    private var pinnedCategoryID: CategoriesCoreData?
    private let context: NSManagedObjectContext
    private let trackersDataStore: TrackersDataStore
    private let categoriesDataStore: CategoriesDataStore
    private let executionsDataStore: ExecutionsDataStore
    
    
    private var insertedIndexes: [IndexPath] = []
    private var deletedIndexes: [IndexPath] = []
    private var updatedIndexes: [IndexPath] = []
    private var insertedSections: IndexSet = []
    private var deletedSections: IndexSet = []
    private var updatedSections: IndexSet = []
    private var movedIndexes: [(from: IndexPath, to: IndexPath)] = []
    
    
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
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key:"trackerToCategory.creationDate", ascending: true),
            NSSortDescriptor(key: "creationDate", ascending: true)]
        
        fetchRequest.predicate = giveTrackersPredicate(kind: currentPredicateType)
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
//            sectionNameKeyPath: "categoryId",
            sectionNameKeyPath: "trackerToCategory",
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
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(generateUdate())
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            
        case .delete:
            deletedSections.insert(sectionIndex)
        case .insert:
            insertedSections.insert(sectionIndex)
        case .update:
            updatedSections.insert(sectionIndex)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes.append(indexPath)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes.append(indexPath)
            }
        case .update:
            if let indexPath = indexPath {
                updatedIndexes.append(indexPath)
            }
        case .move:
            if let indexPath,
               let newIndexPath {
                movedIndexes.append((indexPath, newIndexPath))
            }
        default:
            break
        }
    }
    
    private func generateUdate() -> TrackersDataUpdate {
        let result =  TrackersDataUpdate(
            insertedIndexes: insertedIndexes,
            deletedIndexes: deletedIndexes,
            updatedIndexes: updatedIndexes,
            movedIndexes: movedIndexes,
            insertedSections: insertedSections,
            deletedSections: deletedSections,
            updatedSections: updatedSections
        )
        insertedIndexes = []
        deletedIndexes = []
        updatedIndexes = []
        movedIndexes = []
        insertedSections = []
        deletedSections = []
        updatedSections = []
        
        return result
        
    }
    
    private func giveCategoriesPredicate(kind: TrackerPredicateType = .defaultPredicate) -> NSPredicate {
        switch kind {
        case .defaultPredicate:
            if typedText.isEmpty {
                return NSPredicate(format: "(ANY categoryToTrackers.shedule CONTAINS %@) OR (ANY categoryToTrackers.shedule == '')",
                                   String(selectedDate.weekDayNum))
            } else {
                return NSPredicate(format: "((ANY categoryToTrackers.shedule CONTAINS %@) OR (ANY categoryToTrackers.shedule == '')) AND ANY categoryToTrackers.title CONTAINS[cd] %@",
                                   String(selectedDate.weekDayNum), typedText)
            }
        case .allTrackers:
            return NSPredicate(format: "(ANY categoryToTrackers.shedule CONTAINS %@) OR (ANY categoryToTrackers.shedule == '')",
                               String(selectedDate.weekDayNum))

        case .todayTrackers:
            return NSPredicate(format: "(ANY categoryToTrackers.shedule CONTAINS %@) OR (ANY categoryToTrackers.shedule == '')",
                               String(SimpleDate(date:Date()).weekDayNum))

        case .completedTrackers:
            print(selectedDate.date)
            return NSPredicate(format: "SUBQUERY(categoryToTrackers, $tracker, ANY $tracker.trackerToExecutions.date == %@).@count > 0", Date() as NSDate)

        case .uncompletedTrackers:
            print(selectedDate.date)
            return NSPredicate(format: "SUBQUERY(categoryToTrackers, $tracker, NONE $tracker.trackerToExecutions.date == %@).@count = 0", Date() as NSDate)
        }
    }
    
    private func giveTrackersPredicate(kind: TrackerPredicateType = .defaultPredicate) -> NSPredicate {
        switch kind {
        case .defaultPredicate:
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
        case .allTrackers:
            return NSPredicate(format: "(%K CONTAINS %@) OR (%K == '')",
                               #keyPath(TrackersCoreData.shedule), String(selectedDate.weekDayNum),
                               #keyPath(TrackersCoreData.shedule))
        case .todayTrackers:
            return NSPredicate(format: "(%K CONTAINS %@) OR (%K == '')",
                               #keyPath(TrackersCoreData.shedule), String(SimpleDate(date:Date()).weekDayNum),
                               #keyPath(TrackersCoreData.shedule))
        case .completedTrackers:
            print(selectedDate.date)
            return NSPredicate(format: "ANY %K.date == %@", #keyPath(TrackersCoreData.trackerToExecutions), Date() as NSDate)

        case .uncompletedTrackers:
            print(selectedDate.date)
            return NSPredicate(format: "NONE %K.date == %@", #keyPath(TrackersCoreData.trackerToExecutions), Date() as NSDate)
        }
    }
    
    private func reloadData() {
        categoriesFetchedResultsController.fetchRequest.predicate = giveCategoriesPredicate(kind: currentPredicateType)
        trackersFetchedResultsController.fetchRequest.predicate = giveTrackersPredicate(kind: currentPredicateType)
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
    func setPredicate(predicate: TrackerPredicateType) {
        currentPredicateType = predicate
    }
    
    func setDate(date: SimpleDate) {
        self.selectedDate  = date
    }
    
    func setQuery(query: String) {
        self.typedText = query
    }
    
    var numberOfSections: Int {
        let result = trackersFetchedResultsController.sections?.count ?? .zero
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
    
    func addCategory(_ category: TrackerCategory, isAutomatic: Bool) throws {
        try categoriesDataStore.add(category, isAutomatic)
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
        } catch _ as NSError {
            return nil
        }
    }
    
    func addTracker(_ tracker: Tracker, categoryId: UUID, categoryTitle: String) throws {
        try trackersDataStore.add(tracker, categoryId: categoryId, categoryTitle: categoryTitle)
    }
    
    func editTracker(_ tracker: Tracker) throws {
        try trackersDataStore.edit(tracker)
    }
    
    func interactWith(_ trackerId: UUID, _ date: SimpleDate, indexPath: IndexPath) throws {
        try executionsDataStore.interactWith(trackerId, date)
        if currentPredicateType == .completedTrackers || currentPredicateType == .uncompletedTrackers {
            delegate?.reloadData()
        } else {
            delegate?.reloadItems(at: [indexPath])
        }
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
            
            if let cat = categories.first {
                let check = cat.isAutomatic && cat.title == AutomaticCategories.pinned.rawValue
                return check ? L10n.pinned : cat.title
            } else {
                return nil
            }
        } catch _ as NSError {
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
        
        checkPinnedCategory()
    }
    
    func giveMeAllCategories(filterType: CategoryFilterType) -> [TrackerCategory] {
        let fetchRequest = NSFetchRequest<CategoriesCoreData>(entityName: "CategoriesCoreData")
        switch filterType {
        case .automatic:
            fetchRequest.predicate = NSPredicate(format: "isAutomatic == %@", NSNumber(value: true))
        case .manual:
            fetchRequest.predicate = NSPredicate(format: "isAutomatic == %@", NSNumber(value: false))
        case .all:
            break
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        do {
            let categoriesCoreData = try context.fetch(fetchRequest)
            
            return categoriesCoreData.compactMap { coreDataCategory in
                guard let id = coreDataCategory.id, let title = coreDataCategory.title else { return nil }
                return TrackerCategory(id: id, categoryTitle: title)
            }
            
        } catch _ as NSError {
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
            }
        } catch let error as NSError {
            print("Ошибка при удалении категории: \(error.localizedDescription)")
        }
        
        let trackersFetchRequest = NSFetchRequest<TrackersCoreData>(entityName: "TrackersCoreData")
        trackersFetchRequest.predicate = NSPredicate(format: "categoryId == %@", category.id as NSUUID)
        do {
            let fetchedTrackers = try context.fetch(trackersFetchRequest)
            for tracker in fetchedTrackers {
                context.delete(tracker)
            }
            try context.save()
        } catch let error as NSError {
            print("Ошибка при удалении трекеров категории: \(error.localizedDescription)")
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
    
    func checkPinnedCategory() {
        let pinnedCategories = self.giveMeAllCategories(filterType: .automatic).filter { $0.categoryTitle == AutomaticCategories.pinned.rawValue }
        if let id = pinnedCategories.first?.id {
            try? self.pinnedCategoryID = categoriesDataStore.giveMeCategory(with: id)
        } else {
            let newPinnedCategory = TrackerCategory(id: UUID(), categoryTitle: AutomaticCategories.pinned.rawValue)
            do {
                try addCategory(newPinnedCategory, isAutomatic: true)
            } catch {
                return
            }
            checkPinnedCategory()
        }
    }
    
    func interactWithTrackerPinning(_ tracker: TrackersRecord) throws {
        guard let pinnedCategoryID = pinnedCategoryID else { return }
        switch tracker.isPinned {
        case true:
            let targetCategory = self.giveMeAllCategories(filterType: .manual).filter { $0.id == tracker.categoryId }.first
            guard let targetCategory = targetCategory else { return }
            var coreCategory: CategoriesCoreData? = nil
            try? coreCategory = categoriesDataStore.giveMeCategory(with: targetCategory.id)
            if let coreCategory = coreCategory
            {
                try trackersDataStore.chageCategory(for: tracker.trackerId, to: coreCategory)
            }
        case false:
            try trackersDataStore.chageCategory(for: tracker.trackerId, to: pinnedCategoryID)
        }
    }
    
    func categoryConnectedToTracker(trackerId: UUID) -> TrackerCategory? {
        let fetchRequest = NSFetchRequest<CategoriesCoreData>(entityName: "CategoriesCoreData")
        fetchRequest.predicate = NSPredicate(format: "ANY categoryToTrackers.id == %@", trackerId as NSUUID)
        fetchRequest.fetchLimit = 1
        do {
            let fetchedCategories = try context.fetch(fetchRequest)
            if let category = fetchedCategories.first {
                guard let id = category.id, let title = category.title else { return nil }
                return TrackerCategory(id: id, categoryTitle: title)
            } else {
                return nil
            }
        } catch let error as NSError {
            print("Ошибка при извлечении категории: \(error)")
            return nil
        }
    }
}
