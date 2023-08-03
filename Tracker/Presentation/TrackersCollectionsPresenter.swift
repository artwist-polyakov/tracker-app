//
//  TrackersCollectionsPresenter.swift
//  Tracker
//
//  Created by Александр Поляков on 03.08.2023.
//

import Foundation
import UIKit
class TrackersCollectionsPresenter: NSObject {
    let factory = TrackersFactory.shared
    let cellIdentifier = "TrackerCollectionViewCell"
    var viewController: TrackersViewControllerProtocol

    init(vc: TrackersViewControllerProtocol) {
        self.viewController = vc
    }
    
    func quantityTernar(_ quantity: Int) {
        quantity > 0 ? viewController.hideStartingBlock() : viewController.showStartingBlock()
    }
    
}

extension TrackersCollectionsPresenter: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let quantity = factory.trackers.count
        quantityTernar(quantity)
        return quantity
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! TrackerCollectionViewCell
        let tracker = factory.trackers[indexPath.row]
        
        cell.configure(
            text: tracker.title,
            emoji: "🚀",
            sheetColor: (UIColor(named: "\(tracker.color % 18)") ?? UIColor(named: "2"))!,
            quantityText: Mappers.intToDaysGoneMapper(tracker.isDoneAt.count))
        
        return cell
    }
}

extension TrackersCollectionsPresenter: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = (collectionView.frame.width - 9 - 16 * 2) / 2 // 9 for gap, 16 for each side margin
            return CGSize(width: width, height: 148)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 9
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 9
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
}
