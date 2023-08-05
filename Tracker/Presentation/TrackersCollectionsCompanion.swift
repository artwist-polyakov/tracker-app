//
//  TrackersCollectionsCompanion.swift
//  Tracker
//
//  Created by Александр Поляков on 05.08.2023.
//

import Foundation
import UIKit

class TrackersCollectionsCompanion: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    let factory = TrackersFactory.shared
    let cellIdentifier = "TrackerCollectionViewCell"
    var delegate: TrackersCollectionsCompanionDelegate
    var selectedDate: Date?
    var viewController: TrackersViewControllerProtocol
    
    init(vc: TrackersViewControllerProtocol, delegate: TrackersCollectionsCompanionDelegate) {
        self.viewController = vc
        self.delegate = delegate
    }
    
    // UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let quantity = factory.trackers?.count ?? 0
        delegate.quantityTernar(quantity)
        return quantity
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! TrackerCollectionViewCell
        let tracker = factory.trackers?[indexPath.row]
        
        cell.configure(
            text: tracker?.title ??  "",
            emoji: "❤️",
            sheetColor: (UIColor(named: "\((tracker?.color ?? 1) % 18)") ?? UIColor(named: "2"))!,
            quantityText: Mappers.intToDaysGoneMapper(tracker?.isDoneAt.count ?? 0),
            hasMark: tracker?.isDoneAt.contains(SimpleDate(date: Date())) ??  false
        )
        
        cell.onFunctionButtonTapped = { [weak self] in
            self?.delegate.handleFunctionButtonTapped(at: indexPath.row, date: self?.selectedDate ?? Date())
        }
        
        return cell
    }
    
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
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let sampleLabel = UILabel()
        sampleLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        sampleLabel.text = "Sample text"
        sampleLabel.sizeToFit()
        let height = sampleLabel.frame.height + 4
        
        return CGSize(width: collectionView.frame.width, height: height)
    }
}
    
