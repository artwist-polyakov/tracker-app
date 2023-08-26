import Foundation

final class TrackerCategory {
    let id: UUID
    var categoryTitle: String
    
    init(id: UUID, categoryTitle: String) {
        self.id = id
        self.categoryTitle = categoryTitle
    }
}
