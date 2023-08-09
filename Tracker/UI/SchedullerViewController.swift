//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Александр Поляков on 06.08.2023.
//

import Foundation
import UIKit

class SchedullerViewController: UITableViewController {
    
    var daysOfWeek: [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        return dateFormatter.weekdaySymbols
    }
    
    var selectedDays: Set<String> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DayCell")
        title = "Расписание"
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath)
        cell.textLabel?.text = daysOfWeek[indexPath.row]
        
        let switchView = UISwitch(frame: .zero)
        switchView.tag = indexPath.row
        switchView.isOn = selectedDays.contains(daysOfWeek[indexPath.row])
        switchView.addTarget(self, action: #selector(handleSwitchChange(_:)), for: .valueChanged)
        cell.accessoryView = switchView

        return cell
    }

    @objc func handleSwitchChange(_ sender: UISwitch) {
        let day = daysOfWeek[sender.tag]
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
}

