import Foundation

struct Tracker {
    let id: UUID
    var categoryId: UUID
    let color: Int
    let title: String
    let icon: Int
    var isPlannedFor: String // строка вида "137" для отображения дней недели на которые запланирован трекер
    var isPinned: Bool
    
    init(categoryId: UUID,
         color: Int,
         title: String,
         icon: Int,
         isPlannedFor: String,
         isPinned: Bool) {
        self.id = UUID()
        self.categoryId = categoryId
        self.color = color
        self.title = title
        self.icon = icon
        self.isPlannedFor = isPlannedFor
        self.isPinned = isPinned
    }
}
