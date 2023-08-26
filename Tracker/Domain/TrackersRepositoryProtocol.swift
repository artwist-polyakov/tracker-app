import Foundation
protocol TrackersRepositoryProtocol {
    
    func addNewCategory(name:String)
    func getAllTrackers() -> TrackersSearchResponse
    func getAllDataPlannedTo(date:SimpleDate, titleFilter: String?) -> TrackersSearchResponse
    func addNewTrackerToCategory(color: Int,
                                 categoryID: UUID,
                                 trackerName: String,
                                 icon: Int,
                                 plannedDaysOfWeek: String)
    func interactWithTrackerDoneForDate(trackerId:UUID,
                                        date: SimpleDate)
    func howManyDaysIsTrackerDone(trackerId: UUID) -> Int
    func isTrackerDoneAtDate(trackerId: UUID, date: SimpleDate) -> Bool
}
