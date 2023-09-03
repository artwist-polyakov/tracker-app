//
//  OnboardingRepository.swift
//  Tracker
//
//  Created by Александр Поляков on 03.09.2023.
//

import Foundation
class OnboardingRepository: OnboardingRepositoryProtocol {
    private let userDefaults: UserDefaults = .standard
    private let onboardingKey: String = "completedOnboardingTitles"

    func getOnboardingData() -> [OnboardingData] {
        let allData: [OnboardingData] = [
            OnboardingData(title: "Отслеживайте только то, что хотите",
                           buttonText: "Вот это технологии!",
                           imageName: "OnboardingBackgroundBlue"),
            OnboardingData(title: "Даже если это не литры воды и йога",
                           buttonText: "Вот это технологии!",
                           imageName: "OnboardingBackgroundRed"),
        ]
        let completedTitles: [String] = userDefaults.stringArray(forKey: onboardingKey) ?? []
        return allData.filter { !completedTitles.contains($0.title) }
    }

    func makeOnboardingCompleted(title: String) {
        var completedTitles: [String] = userDefaults.stringArray(forKey: onboardingKey) ?? []
        completedTitles.append(title)
        userDefaults.set(completedTitles, forKey: onboardingKey)
    }
}
