import Foundation

enum resultState {
    case start
    case emptyResult
    case showResult(categories: [TrackerCategory])
}

enum navigationState {
    case removeCategory(_ category: TrackerCategory)
    case addCategory
    case editcategory(_ category: TrackerCategory)
    case categorySelected(_ category: TrackerCategory)
    case categoryApproved(_ category: TrackerCategory)
}

final class CategorySelectionViewModel {
    
    private var categories: [TrackerCategory] = []
    var stateClosure: () -> Void = {}
    var navigationClosure: () -> Void = {}
    private(set) var state: resultState = .start {
        didSet {
            stateClosure()
        }
    }
    private(set) var navigationState: navigationState? = nil {
        didSet {
            navigationClosure()
        }
    }
    
    private let interactor = TrackersCollectionsCompanionInteractor.shared
    
    func updateState() {
        categories = interactor.giveMeAllCategories() ?? []
        if categories.isEmpty {
            state = .emptyResult
        } else {
            state = .showResult(categories: categories)
        }
    }
    
    func handleNavigation(action: interactionType) {
        switch action {
        case .add:
            navigationState = .addCategory
        case .remove(let category):
            navigationState = .removeCategory(category)
        case .edit(let category):
            navigationState = .editcategory(category)
        case .select(let category):
            switch navigationState {
            case .categorySelected(let currentCategory) where currentCategory.id == category.id:
                navigationState = .categoryApproved(category)
            default:
                navigationState = .categorySelected(category)
            }
        }
    }

    
    
}
