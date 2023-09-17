struct Mappers {
    
    static func intToIconMapper(_ number:Int) -> String {
        let icons = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶",
                     "🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝","😪"]
        return icons[number % QUANTITY.COLLECTIONS_CELLS.rawValue]
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
    
    static func giveMeAllWeekdaysNames() -> [String:[Int]] {
        
        // отдаст массив: имя дня недели, номер дня недели в мире с
        // воскр день 1, и сортировка дней недели в мире где первый день
        // зависит от локали
        
        let shift = 1 // MARK: - тут будет Int(NSLocalizedString()) 0 для английского
        return [L10n.monday: shifter(2, shift),
                L10n.tuesday: shifter(3, shift),
                L10n.wednesday: shifter(4, shift),
                L10n.thursday: shifter(5, shift),
                L10n.friday: shifter(6, shift),
                L10n.saturday: shifter(7, shift),
                L10n.sunday: shifter(1, shift)]
    }
    
    static private func shifter(_ pos: Int, _ shift: Int) -> [Int] {
        return [pos,((pos+7)-shift)%8]
    }
    
    static func intToDaynameMapper(_ input: Int) -> String {
        return giveMeAllWeekdaysNames().filter ( {$0.value[0] == input} ).first?.key ?? "0"
        
    }
    
    static func sortedStringOfSetWeekdays(_ weekdays: Set<String>) -> String {
        if weekdays.count == 7 {
            return L10n.Every.day
        }
        let shortNames = [L10n.monday:L10n.Monday.short,
                          L10n.tuesday:L10n.Tuesday.short,
                          L10n.wednesday:L10n.Wednesday.short,
                          L10n.thursday:L10n.Thursday.short,
                          L10n.friday:L10n.Friday.short,
                          L10n.saturday:L10n.Saturday.short,
                          L10n.sunday:L10n.Sunday.short]

        let allWeekdaysNames = giveMeAllWeekdaysNames()
        let sortedWeekdays = weekdays.sorted { weekday1, weekday2 in
            guard let value1 = allWeekdaysNames[weekday1.lowercased()],
                  let value2 = allWeekdaysNames[weekday2.lowercased()] else {
                return false
            }
            return value1[1] < value2[1]
        }
        
        let sortedShortNames = sortedWeekdays.compactMap { weekday -> String? in
            return shortNames[weekday.lowercased()]
        }
        
        return sortedShortNames.joined(separator: ", ")
        
    }
    
    
}
