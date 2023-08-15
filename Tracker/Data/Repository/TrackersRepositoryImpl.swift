//
//  TrackersRepositoryImpl.swift
//  Tracker
//
//  Created by Александр Поляков on 06.08.2023.
//

import Foundation
final class TrackersRepositoryImpl: TrackersRepositoryProtocol {
    
    
    
    static let shared = TrackersRepositoryImpl()
    
    private init() {}
    
    // Изначальное наполнение данными
    private var categories: [TrackerCategory] = [
        TrackerCategory(id: UInt(Date().timeIntervalSince1970),
                        categoryTitle: "Домашний тестовый уют",
                        trackers: [
                            Tracker(id: UInt(Date().timeIntervalSince1970),
                                    color: 1,
                                    title: "Тестовый трекер 123",
                                    icon: 1,
                                    isPlannedFor: Set([SimpleDate(date: Date()).weekDayNum]),
                                    isDoneAt: Set()
                                   ),
                            Tracker(id: 1+UInt(Date().timeIntervalSince1970),
                                    color: 1,
                                    title: "Тестовый трекер 123",
                                    icon: 1,
                                    isPlannedFor: Set([SimpleDate(date: Date()).weekDayNum]),
                                    isDoneAt: Set([SimpleDate(date: Date())])
                                   ),
                            Tracker(id: 2+UInt(Date().timeIntervalSince1970),
                                    color: 1,
                                    title: "Тестовый трекер 123",
                                    icon: 1,
                                    isPlannedFor: Set([SimpleDate(date: Date()).weekDayNum]),
                                    isDoneAt: Set([SimpleDate(date: Date())])
                                   )])
    ]
    func getAllTrackers() -> [TrackerCategory] {
        return categories
    }
    
    func getAllCategoriesPlannedTo(date: SimpleDate, titleFilter: String?) -> [TrackerCategory] {
        let dayOfWeek = date.weekDayNum
        print("РЕВЬЮВЕР settings дата: \(date.dayOfWeek)")
        print("РЕВЬЮВЕР русская дата: \(date.dayOfWeekRussian)")
        let filteredCategories = categories.compactMap { category -> TrackerCategory? in
            let filteredTrackers = category.trackers.filter { tracker in
                let matchesDateCondition = tracker.isPlannedFor.contains(dayOfWeek) || tracker.isPlannedFor.isEmpty
                if let titleFilter = titleFilter, !titleFilter.isEmpty {
                    return matchesDateCondition && tracker.title.localizedCaseInsensitiveContains(titleFilter)
                } else {
                    return matchesDateCondition
                }
            }
            
            if !filteredTrackers.isEmpty {
                return TrackerCategory(id: category.id,
                                       categoryTitle: category.categoryTitle,
                                       trackers: filteredTrackers)
            } else {
                return nil
            }
        }
        return filteredCategories
    }
    
    func addNewTrackerToCategory(color: Int, categoryID: UInt, trackerName: String, icon: Int, plannedDaysOfWeek: Set<Int>) {
        if let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) {
            let newTracker = Tracker(id: UInt(Date().timeIntervalSince1970),
                                     color: color, // MARK: когда будем выбирать цвета, надо проставлять
                                     title: trackerName,
                                     icon: icon, // MARK: когда будем выбирать цвета, надо проставлять
                                     isPlannedFor: Set(plannedDaysOfWeek),
                                     isDoneAt: Set<SimpleDate>())
            categories[categoryIndex].trackers.append(newTracker)
        }
    }
    
    func interactWithTrackerDoneForDate(trackerId: UInt, date: SimpleDate) {
        for (categoryIndex, category) in categories.enumerated() {
            if let trackerIndex = category.trackers.firstIndex(where: { $0.id == trackerId }) {
                let isDoneAt = categories[categoryIndex].trackers[trackerIndex].isDoneAt
                if isDoneAt.contains(date) {
                    categories[categoryIndex].trackers[trackerIndex].isDoneAt.remove(date)
                } else {
                    categories[categoryIndex].trackers[trackerIndex].isDoneAt.insert(date)
                }
            }
        }
    }
    
    func addNewCategory(name: String) {
        let newCategory = TrackerCategory(id: UInt(Date().timeIntervalSince1970),
                                          categoryTitle: name)
        categories.append(newCategory)
    }
    
    func howManyDaysIsTrackerDone(trackerId: UInt) -> Int {
        for category in categories {
            if let tracker = category.trackers.first(where: { $0.id == trackerId }) {
                return tracker.isDoneAt.count
            }
        }
        return 0
    }
    
    func isTrackerDoneAtDate(trackerId: UInt, date: SimpleDate) -> Bool {
        for category in categories {
            if let tracker = category.trackers.first(where: { $0.id == trackerId }) {
                return tracker.isDoneAt.contains(date)
            }
        }
        return false
    }
    
}
