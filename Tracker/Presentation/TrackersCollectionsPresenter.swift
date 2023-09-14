import Foundation
import UIKit

enum PRESENTER_ERRORS {
    case NOT_FOUND
    case LETS_PLAN
    case DEFAULT
}

final class TrackersCollectionsPresenter: TrackersCollectionsCompanionDelegate {
    
    func setInteractor(interactor: TrackersCollectionsCompanionInteractor) {
        self.interactor = interactor
    }
    
    func setState(state: PRESENTER_ERRORS) {
        self.state = state
    }
    
    
    static let didReadyNotification = Notification.Name(rawValue: "ready")
    static let didNotReadyNotification = Notification.Name(rawValue: "not ready")
    let repository = TrackersRepositoryImpl.shared
    var interactor: TrackersCollectionsCompanionInteractor? = nil
    let cellIdentifier = "TrackerCollectionViewCell"
    weak var viewController: TrackersViewControllerProtocol?
    private var state: PRESENTER_ERRORS = PRESENTER_ERRORS.DEFAULT
    var selectedDate: Date?
    
    var trackerTypeToFlush: TrackerType = .notSet {
        didSet {
            notifyObservers()
        }
    }
    
    var trackerCategoryToFlush: UUID? {
        didSet {
            notifyObservers()
        }
    }
    
    var trackerCategorynameToFlush: String? {
        didSet {
            notifyObservers()
        }
    }
    var trackerTitleToFlush: String? {
        didSet {
            notifyObservers()
        }
    }
    var trackerIconToFlush: String? {
        didSet {
            notifyObservers()
        }
    }
    var trackerSheduleToFlush: String = "" {
        didSet {
            notifyObservers()
        }
    }
    let trackerIsPinnedToFlush: Bool = false
    
    var trackerColorToFlush: Int? {
        didSet {
            notifyObservers()
        }
    }
    
    init(vc: TrackersViewControllerProtocol) {
        self.viewController = vc
    }
    
    func quantityTernar(_ quantity: Int) {
        guard let vc = viewController else {return}
        vc.updateStartingBlockState(state)
        quantity > .zero ? vc.hideStartingBlock() : vc.showStartingBlock()
    }
    
    func handleClearAllData() {
        interactor?.clearAllCoreData()
    }
    
    func resetState(){
        state = PRESENTER_ERRORS.DEFAULT
    }
    
}

extension TrackersCollectionsPresenter: TrackerTypeDelegate {
    func giveMeSelectedDays() -> [Int] {
        return trackerSheduleToFlush.compactMap { Int(String($0)) }
    }
    
    func giveMeSelectedCategory() -> TrackerCategory? {
        if let id = trackerCategoryToFlush,
           let title = trackerCategorynameToFlush {
            return TrackerCategory(id: id, categoryTitle: title)
        } else {
            return nil
        }
    }
    
    func didSelectTrackerCategory(_ category: TrackerCategory?) {
        if let category = category {
            trackerCategoryToFlush = category.id
            trackerCategorynameToFlush = category.categoryTitle
        } else {
            trackerCategoryToFlush = nil
            trackerCategorynameToFlush = nil
        }
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
        trackerCategoryToFlush = nil
        trackerCategorynameToFlush = nil
    }
    
    func realizeAllFlushProperties() {
        guard let trackerTitle = trackerTitleToFlush,
              let trackerIcon = trackerIconToFlush,
              let trackerColor = trackerColorToFlush,
              let trackseCategory = trackerCategoryToFlush,
              let trackerCategoryName = trackerCategorynameToFlush
        else { return }
        
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
                              isPlannedFor: trackerSheduleToFlush,
                              isPinned: trackerIsPinnedToFlush)
        
        interactor?.addTracker(tracker: tracker, categoryId: trackseCategory, categoryTitle: trackerCategoryName )
        
        clearAllFlushProperties()
        guard let vc = viewController,
              let cv = vc.collectionView
        else {return}
        cv.reloadData()
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
