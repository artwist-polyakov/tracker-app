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
    
    var weekDayNum: Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self.date)
        return weekday
    }
    
    init(date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let y = components.year,
             let m = components.month,
             let d = components.day else {
           fatalError("Ошибка при извлечении компонентов даты")
       }
        year = y
        month = m
        day = d
    }
    
    var date: Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 0   // Устанавливаем часы в 0
        components.minute = 0 // Устанавливаем минуты в 0
        components.second = 0 // Устанавливаем секунды в 0
        components.timeZone = TimeZone.current // Учет текущей временной зоны
        
        guard let localDate = Calendar.current.date(from: components) else {
            print("Ошибка при создании даты")
            return Date()
        }
        let utcDate = localDate.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
        return utcDate
    }
}

extension SimpleDate {
    var dayOfWeekRussian: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self.date).lowercased()
    }
}
