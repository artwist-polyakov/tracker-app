import Foundation
import UIKit
class TrackersCollectionsPresenter: TrackersCollectionsCompanionDelegate {
    
    func setInteractor(interactor: TrackersCollectionsCompanionInteractor) {
        self.interactor = interactor
    }
    
    
    static let didReadyNotification = Notification.Name(rawValue: "ready")
    static let didNotReadyNotification = Notification.Name(rawValue: "not ready")
    let repository = TrackersRepositoryImpl.shared
    var interactor: TrackersCollectionsCompanionInteractor? = nil {
        didSet {
            print("Установлен интерактор")
        }
    }
    let cellIdentifier = "TrackerCollectionViewCell"
    var viewController: TrackersViewControllerProtocol
    
    var selectedDate: Date?

    var trackerTypeToFlush: TrackerType = .notSet {
        didSet {
            notifyObservers()
            print("TrackerTypeToFlush: \(trackerTypeToFlush)")
        }
    }
    
    var trackerCategoryToFlush: UUID? {
        didSet {
            notifyObservers()
            guard let category = trackerCategoryToFlush
            else {print ("TrackerCategoryToFlush: Пусто") ; return}
            print("TrackerCategoryToFlush: \(category)")
        }
    }
    
    var trackerCategorynameToFlush: String? {
        didSet {
            notifyObservers()
            guard let categoryName = trackerCategorynameToFlush
            else {print ("trackerCategorynameToFlush: Пусто") ; return}
            print("trackerCategorynameToFlush: \(categoryName)")
        }
    }
    var trackerTitleToFlush: String? {
        didSet {
            notifyObservers()
            guard let title = trackerTitleToFlush
            else {print ("trackerTitleToFlush: Пусто") ; return}
            print("trackerTitleToFlush: \(title)")
        }
    }
    var trackerIconToFlush: String? {
        didSet {
            notifyObservers()
            guard let icon = trackerIconToFlush
            else {print ("trackerIconToFlush: Пусто") ; return}
            print("trackerIconToFlush: \(icon)")
        }
    }
    var trackerSheduleToFlush: String = "" {
        didSet {
            notifyObservers()
            print("trackerSheduleToFlush: \(trackerSheduleToFlush)")
        }
    }
    var trackerColorToFlush: Int? {
        didSet {
            notifyObservers()
            guard let color = trackerColorToFlush
            else {print ("trackerColorToFlush: Пусто") ; return}
            print("trackerColorToFlush: \(color)")
        }
    }
    
    init(vc: TrackersViewControllerProtocol) {
        self.viewController = vc
    }
    
    func quantityTernar(_ quantity: Int) {
        quantity > 0 ? viewController.hideStartingBlock() : viewController.showStartingBlock()
    }
    
    func handleFunctionButtonTapped(at item: Int, inSection section: Int, date: Date, text: String) {
        let tracker = repository.getAllDataPlannedTo(date: SimpleDate(date:date), titleFilter: text).trackers[item]
        repository.interactWithTrackerDoneForDate(trackerId: tracker.id, date: SimpleDate(date: date))
        self.viewController.collectionView?.reloadItems(at: [IndexPath(row: item, section: section)])        
    }
    
    func handleClearAllData() {
        interactor?.clearAllCoreData()
    }
    
}

extension TrackersCollectionsPresenter: TrackerTypeDelegate {
    func giveMeSelectedDays() -> [Int] {
        return trackerSheduleToFlush.compactMap { Int(String($0)) }
    }
    
    func giveMeSelectedCategory() -> TrackerCategory? {
        
        //        return trackerCategoryToFlush ?? TrackerCategory(id: UInt(Date().timeIntervalSince1970), categoryTitle: "", trackers: [])
        
//        return repository.getAllTrackers().categoryies[0]
        var result  = interactor?.giveMeAnyCategory()
        if let category = interactor?.giveMeAnyCategory() {
            result  = category
        } else {
            result = repository.getAllTrackers().categoryies[0]
        }
        return result
    }
    
    func didSelectTrackerCategory(_ category: UUID) {
        trackerCategoryToFlush = category
    }
    
    func didSelectTrackerType(_ type: TrackerType) {
        trackerTypeToFlush = type
    }
    
    func didSetTrackerTitle(_ title: String) {
        trackerTitleToFlush = title
    }
    
    func didSetTrackerIcon(_ icon: String) {
        trackerIconToFlush = icon
    }
    
    func didSetShedulleToFlush(_ shedule: [Int]) {
        shedule.forEach { trackerSheduleToFlush += String($0)}
    }
    
    func didSetTrackerColorToFlush(_ color: Int) {
        trackerColorToFlush = color + 1 // Нумерация цветов начинается с 1
    }
    
    func didSetTrackerCategoryName(_ categoryName: String) {
        trackerCategorynameToFlush = categoryName
    }
    
    func clearAllFlushProperties() {
        trackerTypeToFlush = .notSet
        trackerTitleToFlush = nil
        trackerIconToFlush = nil
        trackerSheduleToFlush = ""
        trackerColorToFlush = nil
    }
    
    func realizeAllFlushProperties() {
        guard let trackerTitle = trackerTitleToFlush,
              let trackerIcon = trackerIconToFlush,
              let trackerColor = trackerColorToFlush,
              let trackseCategory = trackerCategoryToFlush,
              let trackerCategoryName = trackerCategorynameToFlush
        else {
            print("Не все данные готовы")
            return }
        
        print("Записываю \(trackerTitle), \(trackerIcon), \(trackerSheduleToFlush), \(trackerColor), \(trackseCategory)")
        repository.addNewTrackerToCategory(
            color: trackerColor,
            categoryID: trackseCategory,
            trackerName: trackerTitle,
            icon: Mappers.iconToIntMapper(trackerIcon),
            plannedDaysOfWeek: trackerSheduleToFlush)
        
        
        let tracker = Tracker(categoryId: trackseCategory,
                              color: trackerColor,
                              title: trackerTitle,
                              icon: Mappers.iconToIntMapper(trackerIcon),
                              isPlannedFor: trackerSheduleToFlush)
        
        print("Добравление трекера в презенторе \(tracker) ")
        interactor?.addTracker(tracker: tracker, categoryId: trackseCategory, categoryTitle: trackerCategoryName )
        
        clearAllFlushProperties()
        viewController.collectionView?.reloadData()
        
        
    }
    
    func isReadyToFlush() -> Bool {
        if trackerTypeToFlush == .notSet {
            return false
        } else if trackerTypeToFlush == .irregularEvent {
            return trackerTitleToFlush != nil && trackerIconToFlush != nil && trackerColorToFlush != nil
        } else {
            return trackerTypeToFlush != .notSet && trackerTitleToFlush != nil && trackerIconToFlush != nil && trackerSheduleToFlush != "" && trackerColorToFlush != nil
        }
    }
    
    
    private func notifyObservers(){
        if isReadyToFlush() {
            NotificationCenter.default.post(
                name: TrackersCollectionsPresenter.didReadyNotification,
                object: self,
                userInfo: ["GO": true ])
        } else {
            NotificationCenter.default.post(
                name: TrackersCollectionsPresenter.didNotReadyNotification,
                object: self,
                userInfo: ["GO": false ])
        }
    }
    
    
}
