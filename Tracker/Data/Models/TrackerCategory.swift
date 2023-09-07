import Foundation

final class TrackerCategory {
    let id: UUID
    var categoryTitle: String
    
    init(id: UUID, categoryTitle: String) {
        self.id = id
        self.categoryTitle = categoryTitle
    }
}

extension TrackerCategory: Equatable {
    static func == (lhs: TrackerCategory, rhs: TrackerCategory) -> Bool {
        return lhs.id == rhs.id
    }
}
