import Foundation

enum categoriesResultState {
    case start
    case emptyResult
    case showResult(categories: [TrackerCategory])
}

enum categoriesNavigationState {
    case removeCategory(_ category: TrackerCategory)
    case addCategory
    case editcategory(_ category: TrackerCategory)
    case categorySelected(_ category: TrackerCategory)
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
    
    private let interactor = TrackersCollectionsCompanionInteractor.shared
    
    func refreshState() {
        categories = interactor.giveMeAllCategories() ?? []
        print(categories)
        if categories.isEmpty {
            state = .emptyResult
        } else {
            state = .showResult(categories: categories)
        }
    }
    
    func setNavigationState(state: categoriesNavigationState) {
        navigationState = state
    }
    
    func handleNavigation(action: InteractionType) {
        switch action {
        case .add:
            navigationState = .addCategory
        case .remove(let category):
            interactor.removeCategory(category: category)
            self.refreshState()
            navigationState = .removeCategory(category)
        case .edit(let category):
            navigationState = .editcategory(category)
        case .select(let category):
            switch navigationState {
            case .categorySelected(let currentCategory) where currentCategory == category:
                navigationState = .categoryApproved(category)
            default:
                navigationState = .categorySelected(category)
            }
        }
    }

    
    
}
