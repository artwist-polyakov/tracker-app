//
//  TrackersCollectionsPresenter.swift
//  Tracker
//
//  Created by Александр Поляков on 03.08.2023.
//

import Foundation
import UIKit
class TrackersCollectionsPresenter: TrackersCollectionsCompanionDelegate {
    let factory = TrackersFactory.shared
//    let factory = EmptyTrackersFactory.shared
    let cellIdentifier = "TrackerCollectionViewCell"
    var viewController: TrackersViewControllerProtocol

    var selectedDate: Date?
    init(vc: TrackersViewControllerProtocol) {
        self.viewController = vc
    }
    
    func quantityTernar(_ quantity: Int) {
        quantity > 0 ? viewController.hideStartingBlock() : viewController.showStartingBlock()
    }
    
    func handleFunctionButtonTapped(at row: Int, date: Date) {
        print("ОШИБКА \(row): \(String(describing: factory.trackers))")
        
        guard let trackers = factory.trackers?[row] else {return}
        
        if trackers.isDoneAt.contains(SimpleDate(date: date)) {
            factory.removeDay(to: row, day: SimpleDate(date:date)) {
                print("Удалил день")
            }
        } else {
            factory.addDay(to: row, day: SimpleDate(date:date)) {
                print("Добавил день")
            }
        }
        
        viewController.collectionView?.reloadItems(at: [IndexPath(index: row)])
        
    }
    
}
