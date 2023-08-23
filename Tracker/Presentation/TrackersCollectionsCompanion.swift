//
//  TrackersCollectionsCompanion.swift
//  Tracker
//
//  Created by Александр Поляков on 05.08.2023.
//

import Foundation
import UIKit

class TrackersCollectionsCompanion: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let trackersCollectionCompanionInteractor = TrackersCollectionsCompanionInteractor.shared
    private lazy var dataProvider: TrackersDataProviderProtocol? = {
        let trackersDataStore = (UIApplication.shared.delegate as! AppDelegate).trackersDataStore
        let categoriesDataStore = (UIApplication.shared.delegate as! AppDelegate).categoriesDataStore
        let executionsDataStore = (UIApplication.shared.delegate as! AppDelegate).executionsDataStore
        
        do {
            let provider = try TrackersDataProvider(
                trackersStore: trackersDataStore,
                categoriesStore: categoriesDataStore,
                executionsStore: executionsDataStore,
                delegate: self
            )
            return provider
        } catch let error as NSError {
            Swift.print("Данные недоступны. Ошибка \(error)")
            return nil
        }
    }()
    
    let repository = TrackersRepositoryImpl.shared
    let cellIdentifier = "TrackerCollectionViewCell"
    var delegate: TrackersCollectionsCompanionDelegate
    var selectedDate: Date? {
        didSet {
            dataProvider?.setDate(date: SimpleDate(date: self.selectedDate ?? Date()))
        }
    }
    var typedText: String? {
        didSet {
            dataProvider?.setQuery(query: typedText ?? "")
        }
    }
    var viewController: TrackersViewControllerProtocol
    
    init(vc: TrackersViewControllerProtocol, delegate: TrackersCollectionsCompanionDelegate) {
        self.viewController = vc
        self.delegate = delegate
        super.init()
        trackersCollectionCompanionInteractor.companion = self
        delegate.setInteractor(interactor: trackersCollectionCompanionInteractor)
    }
    
    func addTracker(tracker: Tracker, categoryId: UUID, categoryTitle: String) {
        try? dataProvider?.addTracker(tracker, categoryId: categoryId, categoryTitle:categoryTitle)
    }
    
    // UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataProvider?.numberOfRowsInSection(section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! TrackerCollectionViewCell
        
        if let tracker = dataProvider?.object(at: indexPath) {
            let days = repository.howManyDaysIsTrackerDone(trackerId: tracker.trackerId)
            let isDone = repository.isTrackerDoneAtDate(trackerId: tracker.trackerId, date: SimpleDate(date: selectedDate ?? Date()))
            
            let color = (UIColor(named: "\(1+((tracker.color-1) % QUANTITY.COLLECTIONS_CELLS.rawValue))") ?? UIColor(named: "1"))!
            cell.configure(
                text: tracker.title,
                emoji: Mappers.intToIconMapper(tracker.icon),
                sheetColor: color,
                quantityText: Mappers.intToDaysGoneMapper(days),
                hasMark: isDone
            )
        }
        
        cell.onFunctionButtonTapped = { [weak self] in
            let selectdate = self?.selectedDate ?? Date()
            let text = self?.typedText ?? ""
            if selectdate <= Date() {
                self?.delegate.handleFunctionButtonTapped(at: indexPath.item, inSection: indexPath.section, date: selectdate, text: text)
            } else {
                self?.viewController.showFutureDateAlert()
            }
        }
        
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 9 - 16 * 2) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 16)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {      
        return CGSize(width: collectionView.frame.width, height: 55)
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
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryViewMain
        
//        if kind == UICollectionView.elementKindSectionHeader {
//            let category = repository.getAllDataPlannedTo(date: SimpleDate(date: selectedDate ?? Date()), titleFilter: typedText ?? "").categoryies[indexPath.section]
//            view.titleLabel.text = category.categoryTitle
//        }
//        if kind == UICollectionView.elementKindSectionHeader {
//                if let tracker = dataProvider?.object(at: IndexPath(item: 0, section: indexPath.section)),
//                   let categoryTitle = dataProvider?.categoryTitle(for: tracker.categoryId) {
//                    view.titleLabel.text = categoryTitle
//                }
//            }
        if kind == UICollectionView.elementKindSectionHeader {
            print("Обработка заголовка для секции \(indexPath.section)")
            
            if let tracker = dataProvider?.object(at: IndexPath(item: 0, section: indexPath.section)) {
                print("Найден трекер для секции \(indexPath.section): \(tracker)")
                
                if let categoryTitle = dataProvider?.categoryTitle(for: tracker.categoryId) {
                    print("Найден заголовок категории: \(categoryTitle) для трекера из секции \(indexPath.section)")
                    view.titleLabel.text = categoryTitle
                } else {
                    print("Заголовок категории не найден для трекера из секции \(indexPath.section)")
                }
            } else {
                print("Трекер не найден для секции \(indexPath.section)")
            }
        }
        
        return view
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataProvider?.numberOfSections ?? 0
    }
    
}

extension TrackersCollectionsCompanion: TrackersDataProviderDelegate {
    
    func didUpdate(_ update: TrackersDataUpdate) {
        print("Метод didUpdate вызван.")
        viewController.collectionView?.performBatchUpdates{
            let insertedIndexPaths = update.insertedIndexes.map { IndexPath(item: $0, section: 0) }
            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(item: $0, section: 0) }
            Swift.print("Вставка элементов по индексам: \(insertedIndexPaths)")
            Swift.print("Удаление элементов по индексам: \(deletedIndexPaths)")
            viewController.collectionView?.insertItems(at: insertedIndexPaths)
            viewController.collectionView?.deleteItems(at: deletedIndexPaths)
            
        }
    }
}
