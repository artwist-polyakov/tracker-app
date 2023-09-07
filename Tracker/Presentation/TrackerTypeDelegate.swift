import Foundation

protocol TrackerTypeDelegate: AnyObject {
    func didSelectTrackerType(_ type: TrackerType)
    func didSelectTrackerCategory(_ category: TrackerCategory?)
    func didSetTrackerTitle(_ title: String)
    func didSetTrackerIcon(_ icon: String)
    func didSetShedulleToFlush(_ shedule: [Int])
    func didSetTrackerColorToFlush(_ color: Int)
    func didSetTrackerCategoryName (_ categoryName: String)
    func clearAllFlushProperties()
    func realizeAllFlushProperties()
    func giveMeSelectedCategory() -> TrackerCategory?
    func giveMeSelectedDays() -> [Int]
    func isReadyToFlush() -> Bool
}

enum TrackerType {
    case habit
    case irregularEvent
    case notSet
}
