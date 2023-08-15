//
//  TrackersCollectionsPresenter.swift
//  Tracker
//
//  Created by Александр Поляков on 03.08.2023.
//

import Foundation
import UIKit
class TrackersCollectionsPresenter: TrackersCollectionsCompanionDelegate {
    
    static let didReadyNotification = Notification.Name(rawValue: "ready")
    static let didNotReadyNotification = Notification.Name(rawValue: "not ready")
    let repository = TrackersRepositoryImpl.shared
    
    let cellIdentifier = "TrackerCollectionViewCell"
    var viewController: TrackersViewControllerProtocol
    
    var selectedDate: Date?

    var trackerTypeToFlush: TrackerType = .notSet {
        didSet {
            notifyObservers()
            print("TrackerTypeToFlush: \(trackerTypeToFlush)")
        }
    }
    
    var trackerCategoryToFlush: UInt? {
        didSet {
            notifyObservers()
            guard let category = trackerCategoryToFlush
            else {print ("TrackerCategoryToFlush: Пусто") ; return}
            print("TrackerCategoryToFlush: \(category)")
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
    var trackerSheduleToFlush: Set<Int>? = Set() {
        didSet {
            notifyObservers()
            guard let shedule = trackerSheduleToFlush
            else {print ("trackerSheduleToFlush: Пусто") ; return}
            print("trackerSheduleToFlush: \(shedule)")
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
        let trackerCategory = repository.getAllCategoriesPlannedTo(date: SimpleDate(date:date), titleFilter: text)[section]
        let tracker = trackerCategory.trackers[item]
        
        repository.interactWithTrackerDoneForDate(trackerId: tracker.id, date: SimpleDate(date: date))
        
        //        viewController.collectionView?.reloadItems(at: [IndexPath(item: item, section: section)])
        
        // MARK: TODO продумать как разрешить коллизию, когда полностью исчезает коллеция
        viewController.collectionView?.reloadData()
    }
    
}

extension TrackersCollectionsPresenter: TrackerTypeDelegate {
    func giveMeSelectedDays() -> Set<Int> {
        return trackerSheduleToFlush ?? Set<Int>()
    }
    
    func giveMeSelectedCategory() -> TrackerCategory {
        //        return trackerCategoryToFlush ?? TrackerCategory(id: UInt(Date().timeIntervalSince1970), categoryTitle: "", trackers: [])
        return repository.getAllTrackers()[0]
    }
    
    func didSelectTrackerCategory(_ category: UInt) {
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
    
    func didSetShedulleToFlush(_ shedule: Set<Int>) {
        trackerSheduleToFlush = Set()
        shedule.forEach { trackerSheduleToFlush?.insert($0)}
    }
    
    func didSetTrackerColorToFlush(_ color: Int) {
        trackerColorToFlush = color + 1 // Нумерация цветов начинается с 1
    }
    
    func clearAllFlushProperties() {
        trackerTypeToFlush = .notSet
        trackerTitleToFlush = nil
        trackerIconToFlush = nil
        trackerSheduleToFlush = nil
        trackerColorToFlush = nil
    }
    
    func realizeAllFlushProperties() {
        if trackerSheduleToFlush == nil {
            trackerSheduleToFlush = Set()
        }
        
        
        guard let trackerTitle = trackerTitleToFlush,
              let trackerIcon = trackerIconToFlush,
              let trackerShedule = trackerSheduleToFlush,
              let trackerColor = trackerColorToFlush,
              let trackseCategory = trackerCategoryToFlush
        else {
            print("Не все данные готовы")
            return }
        
        print("Записываю \(trackerTitle), \(trackerIcon), \(trackerShedule), \(trackerColor), \(trackseCategory)")
        repository.addNewTrackerToCategory(
            color: trackerColor,
            categoryID: trackseCategory,
            trackerName: trackerTitle,
            icon: Mappers.iconToIntMapper(trackerIcon),
            plannedDaysOfWeek: trackerShedule)
        
        clearAllFlushProperties()
        viewController.collectionView?.reloadData()
        
        
    }
    
    func isReadyToFlush() -> Bool {
        if trackerTypeToFlush == .notSet {
            return false
        } else if trackerTypeToFlush == .irregularEvent {
            return trackerTitleToFlush != nil && trackerIconToFlush != nil && trackerColorToFlush != nil
        } else {
            return trackerTypeToFlush != .notSet && trackerTitleToFlush != nil && trackerIconToFlush != nil && trackerSheduleToFlush != nil && trackerColorToFlush != nil
        }
    }
    
    
    private func notifyObservers(){
        if isReadyToFlush() {
            print("Уведомление отправлено что данные готовы")
            NotificationCenter.default.post(
                name: TrackersCollectionsPresenter.didReadyNotification,
                object: self,
                userInfo: ["GO": true ])
        } else {
            print("Уведомление отправлено что данные не готовы")
            NotificationCenter.default.post(
                name: TrackersCollectionsPresenter.didNotReadyNotification,
                object: self,
                userInfo: ["GO": false ])
        }
    }
    
    
}
