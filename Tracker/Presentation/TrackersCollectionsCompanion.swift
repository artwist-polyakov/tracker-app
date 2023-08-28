import Foundation
import UIKit

final class TrackersCollectionsCompanion: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
            print("Данные недоступны. Ошибка \(error)")
            return nil
        }
    }()
    
    let repository = TrackersRepositoryImpl.shared
    let cellIdentifier = "TrackerCollectionViewCell"
    weak var delegate: TrackersCollectionsCompanionDelegate?
    var selectedDate: Date? {
        didSet {
            dataProvider?.setDate(date: SimpleDate(date: self.selectedDate ?? SimpleDate(date: Date()).date))
        }
    }
    var typedText: String? {
        didSet {
            delegate?.setState(state: typedText == "" ? PRESENTER_ERRORS.LETS_PLAN : PRESENTER_ERRORS.NOT_FOUND)
            dataProvider?.setQuery(query: typedText ?? "")
        }
    }
    weak var viewController: TrackersViewControllerProtocol?
    
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
    
    func giveMeAnyCategory() -> TrackerCategory? {
        return dataProvider?.giveMeAnyCategory()
    }
    
    func clearAllCoreData() {
        dataProvider?.clearAllCoreData()
    }
    
    func interactWithExecution(trackerId: UUID, date: SimpleDate, indexPath: IndexPath) {
        try? dataProvider?.interactWith(trackerId, date, indexPath: indexPath)
    }
    
    // UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let quantity = dataProvider?.numberOfRowsInSection(section) ?? 0
        guard let servant = delegate else {return quantity}
        servant.quantityTernar(quantity)
        return quantity
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! TrackerCollectionViewCell
        
        if let tracker = dataProvider?.object(at: indexPath) {
            
            let days = tracker.daysDone
            let isDone = tracker.isChecked
            let computedColorName = "\(1 + ((tracker.color - 1) % QUANTITY.COLLECTIONS_CELLS.rawValue))"
            let color: UIColor = {
                guard let color = UIColor(named: computedColorName) else {
                    assertionFailure("ERROR: COLOR \(1+((tracker.color-1) % QUANTITY.COLLECTIONS_CELLS.rawValue)) NOT FOUND")
                    return .systemGray
                }
                return color
            }()
                

            cell.configure(
                text: tracker.title,
                emoji: Mappers.intToIconMapper(tracker.icon),
                sheetColor: color,
                quantityText: Mappers.intToDaysGoneMapper(days),
                hasMark: isDone
            )
        }
        
        cell.onFunctionButtonTapped = { [weak self] in
            let selectdate = self?.selectedDate ?? SimpleDate(date: Date()).date
            guard let id = self?.dataProvider?.object(at: indexPath)?.trackerId
            else {return}
            if selectdate <= SimpleDate(date:Date()).date {
                self?.interactWithExecution(trackerId: id, date: SimpleDate(date: selectdate), indexPath: indexPath)
            } else {
                guard let vc = self?.viewController else {return}
                vc.showFutureDateAlert()
            }
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = 9
        let availableWidth = Int(collectionView.frame.width) - paddingSpace
        let width = availableWidth / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
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
        
        if kind == UICollectionView.elementKindSectionHeader {
            if let tracker = dataProvider?.object(at: IndexPath(item: 0, section: indexPath.section)) {
                if let categoryTitle = dataProvider?.categoryTitle(for: tracker.categoryId) {
                    view.titleLabel.text = categoryTitle
                }
            }
        }
        return view
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("NUMBER OF SECTIONS")
        let count = self.dataProvider?.numberOfSections ?? 0
        self.delegate?.quantityTernar(count)
        return count
    }
}

extension TrackersCollectionsCompanion: TrackersDataProviderDelegate {
    func reloadItems(at indexPaths: [IndexPath]) {
        guard let vc = viewController,
              let cv = vc.collectionView
        else {return}
        cv.reloadItems(at: indexPaths)
        let count = self.dataProvider?.numberOfSections ?? 0
        print("RELOAD ITEMS\(count)")
        self.delegate?.quantityTernar(count)
    }
    
    
    func didUpdate(_ update: TrackersDataUpdate) {
        guard let vc = viewController,
              let cv = vc.collectionView
        else {return}
        cv.performBatchUpdates {
            let insertedIndexPaths = update.insertedIndexes.map { IndexPath(item: $0, section: update.section) }
            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(item: $0, section: update.section) }
            cv.insertItems(at: insertedIndexPaths)
            cv.deleteItems(at: deletedIndexPaths)
        } completion: { _ in
            let count = self.dataProvider?.numberOfSections ?? 0
            self.delegate?.quantityTernar(count)
        }
    }
    
    func reloadData() {
        guard let vc = viewController,
              let cv = vc.collectionView
        else {return}
        cv.reloadData()
        let count = self.dataProvider?.numberOfSections ?? 0
        print("RELOAD \(count)")
        self.delegate?.quantityTernar(count)
    }
}

