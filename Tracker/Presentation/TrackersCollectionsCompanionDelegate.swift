//
//  TrackersCollectionsCompanionDelegate.swift
//  Tracker
//
//  Created by Александр Поляков on 05.08.2023.
//

import Foundation

protocol TrackersCollectionsCompanionDelegate: AnyObject {
    func handleFunctionButtonTapped(at indexPath: Int, date: Date)
    func quantityTernar(_ quantity: Int)
}
