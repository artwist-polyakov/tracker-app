//
//  DayOfWeek.swift
//  Tracker
//
//  Created by Александр Поляков on 06.08.2023.
//

import Foundation

struct DayOfWeek {
    let name: String
    let isOn: Bool
    
    static var localDays: [DayOfWeek] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        return dateFormatter.weekdaySymbols.map { DayOfWeek(name: $0, isOn: false) }
    }
}

