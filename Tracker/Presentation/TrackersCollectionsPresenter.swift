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
