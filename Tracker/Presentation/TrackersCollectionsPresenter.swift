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
    private var functionButtonTappedObserver: NSObjectProtocol?
    var selectedDate: Date?
    init(vc: TrackersViewControllerProtocol) {
        self.viewController = vc
    }
    
    func quantityTernar(_ quantity: Int) {
        quantity > 0 ? viewController.hideStartingBlock() : viewController.showStartingBlock()
    }
    
    func handleFunctionButtonTapped(at indexPath: IndexPath, date: Date) {
        if factory.trackers[indexPath.row].isDoneAt.contains(SimpleDate(date: date)) {
            factory.removeDay(to: indexPath.row, day: SimpleDate(date:date)) {
                print("Удалил день")
            }
        } else {
            factory.addDay(to: indexPath.row, day: SimpleDate(date:date)) {
                print("Добавил день")
            }
        }
        
        viewController.collectionView?.reloadItems(at: [indexPath])
        
    }
    
}

extension TrackersCollectionsPresenter: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let quantity = factory.trackers.count
        quantityTernar(quantity)
        return quantity
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var id: String
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        default:
            id = ""
        }
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryView // 6
        view.titleLabel.text = factory.trackerTitle
        return view
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! TrackerCollectionViewCell
        let tracker = factory.trackers[indexPath.row]
        
        cell.configure(
            text: tracker.title,
            emoji: "❤️",
            sheetColor: (UIColor(named: "\(tracker.color % 18)") ?? UIColor(named: "2"))!,
            quantityText: Mappers.intToDaysGoneMapper(tracker.isDoneAt.count),
            hasMark: tracker.isDoneAt.contains(SimpleDate(date: Date()))
            )
        
        cell.onFunctionButtonTapped = { [weak self] in
            self?.handleFunctionButtonTapped(at: indexPath, date: self?.selectedDate ?? Date())
        }
        
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
