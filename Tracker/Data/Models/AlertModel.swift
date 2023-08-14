//
//  AlertModel.swift
//  Tracker
//
//  Created by Александр Поляков on 10.08.2023.
//

struct AlertModel {
    var title: String
    var message: String
    var primaryButtonText: String
    var primaryButtonCompletion: (() -> ())
    var secondaryButtonText: String?
    var secondaryButtonCompletion: (() -> ())?
}
