//
//  TrackersCollectionsCompanion.swift
//  Tracker
//
//  Created by Александр Поляков on 05.08.2023.
//

import Foundation
import UIKit

class TrackersCollectionsCompanion: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    let repository = TrackersRepositoryImpl.shared
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
        let trackerCategory = repository.getAllCategoriesPlannedTo(date: SimpleDate(date: selectedDate ?? Date()))[section]
        let quantity = trackerCategory.trackers.count
        return quantity
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! TrackerCollectionViewCell
        let trackerCategory = repository.getAllCategoriesPlannedTo(date: SimpleDate(date: selectedDate ?? Date()))[indexPath.section]
        let tracker = trackerCategory.trackers[indexPath.row]
        
        cell.configure(
            text: tracker.title,
            emoji: "❤️",
            sheetColor: ((UIColor(named: "\((tracker.color) % 18)") ?? UIColor(named: "1"))!),
            quantityText: Mappers.intToDaysGoneMapper(tracker.isDoneAt.count),
            hasMark: tracker.isDoneAt.contains(SimpleDate(date: Date()))
        )
        
        cell.onFunctionButtonTapped = { [weak self] in
            self?.delegate.handleFunctionButtonTapped(at: indexPath.item, inSection: indexPath.section, date: self?.selectedDate ?? Date())
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryView
            
        if kind == UICollectionView.elementKindSectionHeader {
            let category = repository.getAllCategoriesPlannedTo(date: SimpleDate(date: selectedDate ?? Date()))[indexPath.section]
            view.titleLabel.text = category.categoryTitle
        }
        
        return view
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let quantity = repository.getAllCategoriesPlannedTo(date: SimpleDate(date: selectedDate ?? Date())).count
        delegate.quantityTernar(quantity)
        return repository.getAllCategoriesPlannedTo(date: SimpleDate(date: selectedDate ?? Date())).count
    }
    
}
    
