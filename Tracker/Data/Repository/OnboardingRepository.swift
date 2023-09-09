import Foundation
class OnboardingRepository: OnboardingRepositoryProtocol {
    private let userDefaults: UserDefaults = .standard
    private let onboardingKey: String = "completedOnboardingTitles"

    func getOnboardingData() -> [OnboardingData] {
        let allData: [OnboardingData] = [
            OnboardingData(title: L10n.Onboarding.Title.first,
                           buttonText: L10n.Onboarding.button,
                           imageName: "OnboardingBackgroundBlue"),
            OnboardingData(title: L10n.Onboarding.Title.second,
                           buttonText: L10n.Onboarding.button,
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
