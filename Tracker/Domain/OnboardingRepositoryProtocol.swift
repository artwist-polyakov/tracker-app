import Foundation
protocol OnboardingRepositoryProtocol {
    func getOnboardingData() -> [OnboardingData]
    func makeOnboardingCompleted(title: String)
}

