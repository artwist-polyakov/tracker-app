//
//  ExecutionRecord.swift
//  Tracker
//
//  Created by Александр Поляков on 21.08.2023.
//

import Foundation

protocol ExecutionsRecord {
    var date: SimpleDate { get }
    var trackerId: UUID { get }
}

struct ExecutionsRecordImpl: ExecutionsRecord {
    let date: SimpleDate
    let trackerId: UUID
}
