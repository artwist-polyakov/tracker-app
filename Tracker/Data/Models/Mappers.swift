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
}
