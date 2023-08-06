//
//  TrackersRepositoryImpl.swift
//  Tracker
//
//  Created by Александр Поляков on 06.08.2023.
//

import Foundation
final class TrackersRepositoryImpl: TrackersRepositoryProtocol {
    
    static let shared = TrackersRepositoryImpl()

    // Изначальное наполнение данными
    private var categories: [TrackerCategory] = [
        TrackerCategory(id: UInt(Date().timeIntervalSince1970),
                        categoryTitle: "Домашний тестовый уют",
                        trackers: [
                            Tracker(id: UInt(Date().timeIntervalSince1970),
                                    color: 1,
                                    title: "Тестовый трекер 123",
                                    icon: 1,
                                    isPlannedFor: Set([SimpleDate(date: Date())]),
                                    isDoneAt: Set([SimpleDate(date: Date())])
                        )])
                        ]
    func getAllTrackers() -> [TrackerCategory] {
        return categories
    }

    func getAllCategoriesPlannedTo(date: SimpleDate) -> [TrackerCategory] {
        return categories.filter { category in
            category.trackers.contains(where: { $0.isPlannedFor.contains(date) })
        }
    }

    func addNewTrackerToCategory(categoryID: UInt, trackerName: String, plannedDate: [SimpleDate]) {
        if let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) {
            let newTracker = Tracker(id: UInt(Date().timeIntervalSince1970),
                                     color: 1, // Вы можете заменить это на другое значение или сделать параметром функции
                                     title: trackerName,
                                     icon: 1, // Аналогично color
                                     isPlannedFor: Set(plannedDate),
                                     isDoneAt: Set<SimpleDate>())
            categories[categoryIndex].trackers.append(newTracker)
        }
    }

    func interactWithTrackerDoneForeDate(trackerId: UInt, date: SimpleDate) {
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
}
