import Foundation
class TrackersRepositoryImplCoreData: TrackersRepositoryProtocol{
    
    
    static let shared = TrackersRepositoryImplCoreData()
    
    func addNewCategory(name: String) {
        return
    }
    
    func getAllTrackers() -> TrackersSearchResponse {
        return TrackersSearchResponse(categoryies: [], trackers: [], executions: [])
    }
    
    func getAllDataPlannedTo(date: SimpleDate, titleFilter: String?) -> TrackersSearchResponse {
        return TrackersSearchResponse(categoryies: [], trackers: [], executions: [])
    }
    
    func addNewTrackerToCategory(color: Int, categoryID: UUID, trackerName: String, icon: Int, plannedDaysOfWeek: String) {
        return
    }
    
    func interactWithTrackerDoneForDate(trackerId: UUID, date: SimpleDate) {
        return
    }
    
    func howManyDaysIsTrackerDone(trackerId: UUID) -> Int {
        return 42
    }
    
    func isTrackerDoneAtDate(trackerId: UUID, date: SimpleDate) -> Bool {
        return true
    }
    

}
