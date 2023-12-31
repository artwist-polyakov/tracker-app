import Foundation
import UIKit

final class TrackersCollectionsCompanion: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let trackersCollectionCompanionInteractor = TrackersCollectionsCompanionInteractor.shared
    private let analyticsService = AnalyticsService()
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
            provider.checkPinnedCategory()
            return provider
        } catch let error as NSError {
            print("Данные недоступны. Ошибка \(error)")
            return nil
        }
    }()
    
    let cellIdentifier = "TrackerCollectionViewCell"
    weak var delegate: TrackersCollectionsCompanionDelegate?
    var selectedDate: Date? {
        didSet {
            dataProvider?.setDate(date: SimpleDate(date: self.selectedDate ?? SimpleDate(date: Date()).date))
            reloadData()
        }
    }
    var typedText: String? {
        didSet {
            delegate?.setState(state: typedText == "" ? PRESENTER_ERRORS.LETS_PLAN : PRESENTER_ERRORS.NOT_FOUND)
            dataProvider?.setQuery(query: typedText ?? "")
            reloadData()
        }
    }
    
    private var selectedPredicate: TrackerPredicateType = .defaultPredicate
    
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
    
    func editTracker(_ tracker: Tracker) {
        try? dataProvider?.editTracker(tracker)
    }
    
    func clearAllCoreData() {
        dataProvider?.clearAllCoreData()
    }
    
    func giveMeAllCategories (filterType: CategoryFilterType = .all) -> [TrackerCategory]? {
        return dataProvider?.giveMeAllCategories(filterType: filterType)
    }
    
    func addCategory (category: TrackerCategory) {
        try? dataProvider?.addCategory(category)
    }
    
    func deleteCategory (category: TrackerCategory) {
        dataProvider?.deleteCategory(category: category)
    }
    
    func editCategory (category: TrackerCategory) {
        dataProvider?.editCategory(category: category)
    }
    
    func giveMeCategoryById(id: UUID) -> TrackerCategory? {
        return dataProvider?.giveMeCategoryById(id: id)
    }
    
    
    func interactWithExecution(trackerId: UUID, date: SimpleDate) {
        try? dataProvider?.interactWith(trackerId, date)
    }
    
    func setPredicate(predicate: TrackerPredicateType) {
        selectedPredicate = predicate
        dataProvider?.setPredicate(predicate: predicate)
    }
    
    func getCurrentPredicate() -> TrackerPredicateType {
        return selectedPredicate
    }
    
    func howManyCompletedTrackers() -> Int {
        return dataProvider?.howManyCompletedTrackers() ?? 0
    }
    
    func haveStats() -> Bool {
        return dataProvider?.haveStats() ?? false
    }
    
    func mostLongSeries() -> Int {
        guard let series = dataProvider?.mostLongSeries() else {return 0}
        return series
    }
    
    
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let quantity = dataProvider?.numberOfRowsInSection(section) ?? .zero
        guard let servant = delegate else {return quantity}
        servant.quantityTernar(quantity)
        return quantity
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { suggestedActions -> UIMenu? in
            guard let tracker = self.dataProvider?.object(at: indexPath)  else {return nil}
            return UIMenu(title: "", children: [
                UIAction(title: tracker.isPinned ? L10n.unpin : L10n.pin) { [weak self] _ in
                    self?.analyticsService.report(event: "click", params: ["screen": "Main","item":"\(tracker.isPinned ? "unpin" : "pin")"])
                    try? self?.dataProvider?.interactWithTrackerPinning(tracker)
                },
                UIAction(title: L10n.edit) { [weak self] _ in
                    self?.analyticsService.report(event: "click", params: ["screen": "Main","item":"edit"])
                    self?.showEditVC(for: indexPath)
                },
                UIAction(title: L10n.delete, attributes: .destructive) { [weak self] _ in
                    self?.analyticsService.report(event: "click", params: ["screen": "Main","item":"delete"])
                    self?.showDeleteConfirmation(for: indexPath)
                }
            ])
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell
        else { return nil }
    
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(roundedRect: cell.viewForContextMenu().bounds, cornerRadius: 16)
        let targetedPreview = UITargetedPreview(view: cell.viewForContextMenu(), parameters: parameters)
        
        return targetedPreview
    }

    private func showDeleteConfirmation(for indexPath: IndexPath) {
        guard let vc = viewController else {return}
        vc.showDeleteConfirmation() { [weak self] in
            try? self?.dataProvider?.deleteObject(at: indexPath)
        }
    }
    
    private func showEditVC(for indexPath: IndexPath) {
        guard let vc = viewController,
              let obj = self.dataProvider?.object(at: indexPath)
        else {return}
        let tracker = Tracker(id: obj.trackerId,
                              categoryId: obj.categoryId,
                              color: obj.color,
                              title: obj.title,
                              icon: obj.icon,
                              isPlannedFor: obj.shedule,
                              isPinned: obj.isPinned)
        let days = obj.daysDone
        vc.launchEditProcess(tracker: tracker, days: days)
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
                quantityText: L10n.daysStrike(days),
                hasMark: isDone
            )
            
            cell.onFunctionButtonTapped = { [weak self] in
                let selectdate = self?.selectedDate ?? SimpleDate(date: Date()).date
                if selectdate <= SimpleDate(date:Date()).date {
                    self?.analyticsService.report(event: "click", params: ["screen": "Main","item":"track"])
                    self?.interactWithExecution(trackerId: tracker.trackerId, date: SimpleDate(date: selectdate))
                } else {
                    guard let vc = self?.viewController else {return}
                    vc.showFutureDateAlert()
                }
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
                if let category = dataProvider?.categoryConnectedToTracker(trackerId: tracker.trackerId) {
                    view.titleLabel.text = dataProvider?.categoryTitle(for: category.id)
                }
            }
        }
        return view
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = self.dataProvider?.numberOfSections ?? .zero
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
        let count = self.dataProvider?.numberOfSections ?? .zero
        self.delegate?.quantityTernar(count)
    }
    
    func didUpdate(_ update: TrackersDataUpdate) {
        guard let vc = viewController,
              let cv = vc.collectionView
        else {return}
        cv.performBatchUpdates {
            
            cv.deleteSections(update.deletedSections)
            cv.insertSections(update.insertedSections)
            cv.reloadSections(update.updatedSections)

            cv.deleteItems(at: update.deletedIndexes)
            cv.insertItems(at: update.insertedIndexes)
            
            for move in update.movedIndexes {
                cv.moveItem(at: move.from, to: move.to)
            }
            
            cv.reloadItems(at: update.updatedIndexes)
        } completion: { _ in
            let count = self.dataProvider?.numberOfSections ?? .zero
            self.delegate?.quantityTernar(count)
        }
    }
    
    func reloadData() {
        guard let vc = viewController,
              let cv = vc.collectionView
        else { return }
        cv.reloadData()
        let count = self.dataProvider?.numberOfSections ?? .zero
        self.delegate?.quantityTernar(count)
    }
    
    
}

