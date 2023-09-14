import Foundation

enum categoriesResultState {
    case start
    case emptyResult
    case showResult(categories: [TrackerCategory], update: [Int]? = nil)
}

enum categoriesNavigationState {
    case removeCategory(_ category: TrackerCategory)
    case addCategory
    case editcategory(_ category: TrackerCategory)
    case categorySelected(_ pos: Int)
    case categoryApproved(_ category: TrackerCategory)
}

final class CategorySelectionViewModel: CategorySelectionViewModelDelegate {
    
    private var categories: [TrackerCategory] = []
    var stateClosure: () -> Void = {}
    var navigationClosure: () -> Void = {}
    private(set) var state: categoriesResultState = .start {
        didSet {
            stateClosure()
        }
    }
    private(set) var navigationState: categoriesNavigationState? = nil {
        didSet {
            navigationClosure()
        }
    }
    
    private(set) var updatingRows:[Int] = []
    private var currentSelectionPos: Int? = nil
    
    private let interactor = TrackersCollectionsCompanionInteractor.shared
    
    func refreshState() {
        categories = interactor.giveMeAllCategories() ?? []
        print("ОШИБКА \(categories)")
        if categories.isEmpty {
            state = .emptyResult
        } else {
            state = .showResult(categories: categories)
        }
    }
    
    func setNewCategorySelected() {
        let pos = howManyCategories() - 1
        navigationState = .categorySelected(pos)
        currentSelectionPos = pos
    }
    
    func setCategorySelected(category: TrackerCategory) {
        refreshState()
        if let pos = categories.firstIndex(of: category) {
            navigationState = .categorySelected(pos)
            currentSelectionPos = pos
        }
    }
    
    func howManyCategories() -> Int {
        return categories.count
    }
    
    func giveMeCategory(pos: Int) -> TrackerCategory? {
        if pos >= categories.count {
            return nil
        }
        return categories[pos]
    }
    
    func isNotCheckedCategory(pos: Int) -> Bool {
        return pos != currentSelectionPos
    }
    
    func handleNavigation(action: InteractionType) {
        switch action {
        case .add:
            navigationState = .addCategory
        case .remove(let pos):
            if pos >= categories.count {
                return
            }
            let category = categories[pos]
            interactor.removeCategory(category: category)
            self.refreshState()
            navigationState = .removeCategory(category)
        case .edit(let pos):
            if pos >= categories.count {
                return
            }
            let category = categories[pos]
            navigationState = .editcategory(category)
        case .select(let posView):
            switch navigationState {
            case .categorySelected(let posModel) where posModel == posView:
                navigationState = .categoryApproved(categories[posModel])
            default:
                navigationState = .categorySelected(posView)
                var paths = [posView]
                if let oldPath = currentSelectionPos {
                    paths.append(oldPath)
                }
                currentSelectionPos = posView
                state = .showResult(categories: categories, update: paths)
            }
        }
    }
}
