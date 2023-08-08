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
    
    var trackerTypeToFlush: TrackerType?
    var trackerCategoryToFlush: TrackerCategory?
    var trackerTitleToFlush: String?
    var trackerIconToFlush: String?
    var trackerSheduleToFlush: Set<String>?
    var trackerColorToFlush: Int?
    
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
        return trackerCategoryToFlush ?? TrackerCategory(id: UInt(Date().timeIntervalSince1970), categoryTitle: "", trackers: [])
    }
    
    func didSelectTrackerCategory(_ category: TrackerCategory) {
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
        trackerTypeToFlush = nil
        trackerTitleToFlush = nil
        trackerIconToFlush = nil
        trackerSheduleToFlush = nil
        trackerColorToFlush = nil
    }
    
    func realizeAllFlushProperties() {
        print("HA-HA-HA")
    }
    
    
    
}
