//
//  TrackerTypeViewController.swift
//  Tracker
//
//  Created by Александр Поляков on 06.08.2023.
//

import Foundation
import UIKit
class TrackerTypeViewController: UIViewController {
    weak var delegate: TrackerTypeDelegate?
    let buttonsContainer = UIView()
    let habitButton = UIButton(type: .system)
    let irregularEventButton = UIButton(type: .system)
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "TrackerBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        setupButtons()
        layoutButtons()
    }
    
    private func setupButtons() {
        // Настройка кнопки "Привычка"
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.backgroundColor = UIColor(named: "TrackerBlack")
        habitButton.setTitleColor(UIColor(named: "TrackerWhite"), for: .normal)
        habitButton.layer.cornerRadius = 16
        habitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        habitButton.addTarget(self, action: #selector(handleHabitButton), for: .touchUpInside)
        
        // Настройка кнопки "Нерегулярное событие"
        irregularEventButton.setTitle("Нерегулярное событие", for: .normal)
        irregularEventButton.backgroundColor = UIColor(named: "TrackerBlack")
        irregularEventButton.setTitleColor(UIColor(named: "TrackerWhite"), for: .normal)
        irregularEventButton.layer.cornerRadius = 16
        irregularEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        irregularEventButton.addTarget(self, action: #selector(handleIrregularEventButton), for: .touchUpInside)
    }

    
    private func layoutButtons() {
        self.view.addSubview(buttonsContainer)
        buttonsContainer.addSubview(habitButton)
        buttonsContainer.addSubview(irregularEventButton)
        
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        irregularEventButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Ограничения для контейнера
            buttonsContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            buttonsContainer.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            buttonsContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            buttonsContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            
            // Ограничения для кнопки "Привычка"
            habitButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            habitButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            habitButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Ограничения для кнопки "Нерегулярное событие"
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularEventButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            irregularEventButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
            irregularEventButton.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    
    @objc private func handleHabitButton() {
        delegate?.didSelectTrackerType(.habit)
        let createTrackerViewController = CreateTrackerViewController()
        createTrackerViewController.delegate = delegate
        createTrackerViewController.selectedTrackerType = .habit
        navigationController?.pushViewController(createTrackerViewController, animated: true)
        // Переход к экрану создания трекера с выбором "Привычка"
    }
    
    @objc private func handleIrregularEventButton() {
        delegate?.didSelectTrackerType(.irregularEvent)
        let createTrackerViewController = CreateTrackerViewController()
        createTrackerViewController.delegate = delegate
        createTrackerViewController.selectedTrackerType = .irregularEvent
        navigationController?.pushViewController(createTrackerViewController, animated: true)
        // Переход к экрану создания трекера с выбором "Нерегулярное событие"
    }
}
