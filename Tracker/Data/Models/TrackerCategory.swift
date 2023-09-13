import Foundation

final class TrackerCategory: CustomStringConvertible {
    let id: UUID
    var categoryTitle: String
    
    init(id: UUID, categoryTitle: String) {
        self.id = id
        self.categoryTitle = categoryTitle
    }
    
    var description: String {
            return "TrackerCategory - ID: \(id), Title: \(categoryTitle)"
        }
}

extension TrackerCategory: Equatable {
    static func == (lhs: TrackerCategory, rhs: TrackerCategory) -> Bool {
        return lhs.id == rhs.id
    }
}
