//
//  TrackersStorage.swift
//  Tracker
//
//  Created by Александр Поляков on 05.08.2023.
//

import Foundation
final class TrackersStorage {
    static let shared = TrackersStorage()
    var store: [TrackersStorageProtocol]?
}
