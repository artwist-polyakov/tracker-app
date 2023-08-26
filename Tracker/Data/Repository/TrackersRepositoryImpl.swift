import Foundation

final class TrackersRepositoryImpl: TrackersRepositoryProtocol {
    
    static let shared = TrackersRepositoryImpl()
    
    private init() {}
    
    
    // MARK: - Изначальное наполнение данными
    private var categories: [TrackerCategory] = [
        TrackerCategory(id: UUID(), categoryTitle: "Домашний тестовый уют")
    ]
    
    private lazy var trackers: [Tracker] = [
        Tracker(categoryId: categories[0].id,
                color: 1,
                title: "Тестовый трекер 123",
                icon: 1,
                isPlannedFor: String(SimpleDate(date: Date()).weekDayNum)
               ),
        
        Tracker(categoryId: categories[0].id,
                color: 1,
                title: "Тестовый трекер 123",
                icon: 1,
                isPlannedFor: String(SimpleDate(date: Date()).weekDayNum)
               ),
        
        Tracker(categoryId: categories[0].id,
                color: 1,
                title: "Тестовый трекер 123",
                icon: 1,
                isPlannedFor: String(SimpleDate(date: Date()).weekDayNum)
               )
    ]
    
    private lazy var executions: [Execution] = [
        Execution(day: SimpleDate(date: Date()), trackerId: trackers[1].id),
        Execution(day: SimpleDate(date: Date()), trackerId: trackers[2].id)
    ]
    
    func getAllTrackers() -> TrackersSearchResponse {
        let response = TrackersSearchResponse(categoryies: categories, trackers: trackers, executions: executions)
        return response
    }
    
    func getAllDataPlannedTo(date: SimpleDate, titleFilter: String?) -> TrackersSearchResponse {
        let dayOfWeek = String(date.weekDayNum)
        
        // Фильтруем трекеры по дате и названию
        let filteredTrackers = trackers.filter { tracker in
            let matchesDateCondition = tracker.isPlannedFor.contains(dayOfWeek) || tracker.isPlannedFor.isEmpty
            if let titleFilter = titleFilter, !titleFilter.isEmpty {
                return matchesDateCondition && tracker.title.localizedCaseInsensitiveContains(titleFilter)
            } else {
                return matchesDateCondition
            }
        }
        
        // Получаем уникальные категории для отфильтрованных трекеров
        let filteredCategoryIds = Set(filteredTrackers.map { $0.categoryId })
        let filteredCategories = categories.filter { filteredCategoryIds.contains($0.id) }
        
        // Фильтруем выполнения по отфильтрованным трекерам
        let filteredTrackerIds = Set(filteredTrackers.map { $0.id })
        let filteredExecutions = executions.filter { filteredTrackerIds.contains($0.trackerId) }
        
        return TrackersSearchResponse(categoryies: filteredCategories, trackers: filteredTrackers, executions: filteredExecutions)
    }
    
    
    func addNewTrackerToCategory(color: Int, categoryID: UUID, trackerName: String, icon: Int, plannedDaysOfWeek: String) {
        let newTracker = Tracker(categoryId: categoryID,
                                 color: color,
                                 title: trackerName,
                                 icon: icon,
                                 isPlannedFor: plannedDaysOfWeek)
        
        trackers.append(newTracker)
    }
    
    func interactWithTrackerDoneForDate(trackerId: UUID, date: SimpleDate) {
        // Попробуем найти индекс выполнения в массиве executions
        if let executionIndex = executions.firstIndex(where: { $0.trackerId == trackerId && $0.day == date }) {
            // Если выполнение найдено, удаляем его
            executions.remove(at: executionIndex)
        } else {
            // В противном случае добавляем новое выполнение в массив
            let newExecution = Execution(day: date, trackerId: trackerId)
            executions.append(newExecution)
        }
    }
    
    func addNewCategory(name: String) {
        let newCategory = TrackerCategory(id: UUID(), categoryTitle: name)
        categories.append(newCategory)
    }
    
    func howManyDaysIsTrackerDone(trackerId: UUID) -> Int {
        return executions.filter { $0.trackerId == trackerId }.count
    }
    
    func isTrackerDoneAtDate(trackerId: UUID, date: SimpleDate) -> Bool {
        return executions.contains(where: { $0.trackerId == trackerId && $0.day == date })
    }
}
