//
//  TrackersSearchResponse.swift
//  Tracker
//
//  Created by Александр Поляков on 21.08.2023.
//

import Foundation
struct TrackersSearchResponse {
    let categoryies: [TrackerCategory]
    let trackers: [Tracker]
    let executions: [Execution]
}
