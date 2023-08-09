//
//  TrackersCollectionsPresenter.swift
//  Tracker
//
//  Created by Александр Поляков on 03.08.2023.
//

import Foundation
import UIKit
class TrackersCollectionsPresenter: TrackersCollectionsCompanionDelegate {
    let repository = TrackersRepositoryImpl.shared

    let cellIdentifier = "TrackerCollectionViewCell"
    var viewController: TrackersViewControllerProtocol

    var selectedDate: Date?
    
    var trackerTypeToFlush: TrackerType = .notSet {
        didSet {
            print("TrackerTypeToFlush: \(trackerTypeToFlush)")
        }
    }
        
    var trackerCategoryToFlush: UInt? {
        didSet {
            guard let category = trackerCategoryToFlush
            else {print ("TrackerCategoryToFlush: Пусто") ; return}
            print("TrackerCategoryToFlush: \(category)")
        }
    }
    var trackerTitleToFlush: String? {
        didSet {
            guard let title = trackerTitleToFlush
            else {print ("trackerTitleToFlush: Пусто") ; return}
            print("trackerTitleToFlush: \(title)")
        }
    }
    var trackerIconToFlush: String? {
        didSet {
            guard let icon = trackerIconToFlush
            else {print ("trackerIconToFlush: Пусто") ; return}
            print("trackerIconToFlush: \(icon)")
        }
    }
    var trackerSheduleToFlush: Set<String>? {
        didSet {
            guard let shedule = trackerSheduleToFlush
            else {print ("trackerSheduleToFlush: Пусто") ; return}
            print("trackerSheduleToFlush: \(shedule)")
        }
    }
    var trackerColorToFlush: Int? {
        didSet {
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
    
    func handleFunctionButtonTapped(at item: Int, inSection section: Int, date: Date) {
        let trackerCategory = repository.getAllTrackers()[section]
        let tracker = trackerCategory.trackers[item]

        repository.interactWithTrackerDoneForDate(trackerId: tracker.id, date: SimpleDate(date: date))
        
//        viewController.collectionView?.reloadItems(at: [IndexPath(item: item, section: section)])
        
        // MARK: TODO продумать как разрешить коллизию, когда полностью исчезает коллеция
        viewController.collectionView?.reloadData()
    }
    
}

extension TrackersCollectionsPresenter: TrackerTypeDelegate {
    func giveMeSelectedDays() -> Set<String> {
        return trackerSheduleToFlush ?? Set<String>()
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
    
    func didSetShedulleToFlush(_ shedule: Set<String>) {
        trackerSheduleToFlush = shedule
    }
    
    func didSetTrackerColorToFlush(_ color: Int) {
        trackerColorToFlush = color
    }
    
    func clearAllFlushProperties() {
        trackerTypeToFlush = .notSet
        trackerTitleToFlush = nil
        trackerIconToFlush = nil
        trackerSheduleToFlush = nil
        trackerColorToFlush = nil
    }
    
    func realizeAllFlushProperties() {
        print("HA-HA-HA")
    }
    
    func isReadyToFlush() -> Bool {
        return trackerTypeToFlush != .notSet && trackerTitleToFlush != nil && trackerIconToFlush != nil && trackerSheduleToFlush != nil && trackerColorToFlush != nil
    }
    
    
    
}
