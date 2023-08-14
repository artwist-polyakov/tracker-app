//
//  MenuItem.swift
//  Tracker
//
//  Created by Александр Поляков on 07.08.2023.
//

import Foundation

struct MenuItem {
    let title: String
    var subtitle: String
    let action: () -> Void
}
