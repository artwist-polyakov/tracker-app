import Foundation

struct PredicateElement {
    let title: String
    let predicate: TrackerPredicateType
    var isOn: Bool
}

enum FilterState {
    case start
    case show(cases: [PredicateElement], update: [Int]? = nil)
}

enum FilterNavigationState {
    case filterSelected(_ pos: Int)
    case filterApproved(_ filter: PredicateElement)
}

final class FiltersTrackerViewModel: FiltersViewModelDelegate {
    
    private var cases: [PredicateElement] = [
        PredicateElement(title: "Все трекеры", predicate: .allTrackers, isOn: false),
        PredicateElement(title: "Трекеры на сегодня", predicate: .todayTrackers, isOn: false),
        PredicateElement(title: "Завершенные", predicate: .completedTrackers, isOn: false),
        PredicateElement(title: "Не завершенные", predicate: .uncompletedTrackers, isOn: false),
    ]
    
    var stateClosure: () -> Void = {}
    var navigationClosure: () -> Void = {}
    
    private(set) var state: FilterState = .start {
        didSet {
            stateClosure()
        }
    }
    
    private(set) var navigationState: FilterNavigationState? = nil {
        didSet {
            navigationClosure()
        }
    }
    
    private(set) var updatingRows:[Int] = []
    private var currentSelectionPos: Int = -1
    
    private let interactor = TrackersCollectionsCompanionInteractor.shared
    
    func refreshState() {
        state = .show(cases: cases)
    }
    
    func setFilterSelected(_ type: TrackerPredicateType) {
        print("я вьюимодель инициализирую предикат")
        guard let pos = cases.firstIndex(where: { $0.predicate == type }) else { return }
        print(pos)
        cases[pos].isOn = true
        print(cases)
        var paths = [pos]
        currentSelectionPos = pos
        state = .show(cases: cases, update: [pos])
        navigationState = .filterSelected(pos)
        refreshState()
    }
    
    func howManyFilters() -> Int {
        return cases.count
    }
    
    func giveMeFilter(pos: Int) -> PredicateElement? {
        if pos >= cases.count {
            return nil
        }
        return cases[pos]
    }
    
    func isNotCheckedFilter(pos: Int) -> Bool {
        return pos != currentSelectionPos
    }
    
    func handleTap(pos: Int) {
        if let nav = navigationState {
            switch nav {
            case .filterSelected(let position) where pos != position:
                var paths = [pos]
                if currentSelectionPos != -1 {
                    paths.append(currentSelectionPos)
                    cases[currentSelectionPos].isOn.toggle()
                }
                currentSelectionPos = pos
                cases[pos].isOn.toggle()
                navigationState = .filterSelected(pos)
                state = .show(cases: cases, update: paths)
            default:
                guard let filter = giveMeFilter(pos: pos) else { return }
                navigationState = .filterApproved(filter)
            }
        } else {
            navigationState = .filterSelected(pos)
            cases[pos].isOn.toggle()
            let paths = [pos]
            currentSelectionPos = pos
            state = .show(cases: cases, update: paths)
        }
    }
}
