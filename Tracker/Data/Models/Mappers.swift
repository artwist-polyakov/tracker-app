//
//  Mappers.swift
//  Tracker
//
//  Created by Александр Поляков on 03.08.2023.
//

struct Mappers {
    
    static func intToDaysGoneMapper (_ number: Int) -> String {
        var result  = "\(number)"
        if (result.hasSuffix("12") || result.hasSuffix("11")) {
            result += " дней"
        } else if result.hasSuffix("1") {
            result += " день"
        } else if result.hasSuffix("2") || result.hasSuffix("3") || result.hasSuffix("4") {
            result += " дня"
        } else {
            result += " дней"
        }
        return result
    }
    
    static func intToIconMapper(_ number:Int) -> String {
        let icons = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶",
                     "🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝","😪"]
        return icons[number % 18]
    }
    
    static func iconToIntMapper(_ icon:String) -> Int {
        let icons = ["🙂":0,
                     "😻":1,
                     "🌺":2,
                     "🐶":3,
                     "❤️":4,
                     "😱":5,
                     "😇":6,
                     "😡":7,
                     "🥶":8,
                     "🤔":9,
                     "🙌":10,
                     "🍔":11,
                     "🥦":12,
                     "🏓":13,
                     "🥇":14,
                     "🎸":15,
                     "🏝":16,
                     "😪":17]
        return icons[icon] ?? 0
    }
    
    static func giveMeAllWeekdaysNames() -> [String:Int] {
        return ["понедельник":1,
                "вторник":2,
                "среда":3,
                "четверг":4,
                "пятница":5,
                "суббота":6,
                "воскресенье":7]
    }
    
    static func sortedStringOfSetWeekdays(_ weekdays: Set<String>) -> String {
        if weekdays.count == 7 {
            return "Каждый день"
        }
        let short_names = ["понедельник":"Пн",
                           "вторник":"Вт",
                           "среда":"Ср",
                           "четверг":"Чт",
                           "пятница":"Пт",
                           "суббота":"Сб",
                           "воскресенье":"Вс"]
        
        let sortedWeekdays = weekdays.sorted {
            return giveMeAllWeekdaysNames()[$0.lowercased()]! < giveMeAllWeekdaysNames()[$1.lowercased()]!
        }
        
        let sortedShortNames = sortedWeekdays.map { short_names[$0.lowercased()]! }
        
        return sortedShortNames.joined(separator: ", ")
        
    }
    
    
}
