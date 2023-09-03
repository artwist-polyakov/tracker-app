//
//  OnboardingRepositoryProtocol.swift
//  Tracker
//
//  Created by Александр Поляков on 03.09.2023.
//

import Foundation
protocol OnboardingRepositoryProtocol {
    func getOnboardingData() -> [OnboardingData]
    func makeOnboardingCompleted(title: String)
}

