//
//  SimpleDate.swift
//  Tracker
//
//  Created by Александр Поляков on 04.08.2023.
//

import Foundation

struct SimpleDate: Hashable {
    let year: Int
    let month: Int
    let day: Int
    
    var dayOfWeek: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self.date)
    }
    
    init(date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        year = components.year!
        month = components.month!
        day = components.day!
    }
    
    var date: Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)!
    }
    
    
}
