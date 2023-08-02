//
//  ViewController.swift
//  Tracker
//
//  Created by Александр Поляков on 27.07.2023.
//

import UIKit

class TrackersViewController: UIViewController {
    
    let addBarButtonItem: UIBarButtonItem = {
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: "Add"), for: .normal)
            button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
            let barButtonItem = UIBarButtonItem(customView: button)
            return barButtonItem
        }()

        let datePicker: UIDatePicker = {
                let picker = UIDatePicker()
                picker.datePickerMode = .date
                return picker
            }()
    
    let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "Трекеры"
            label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
            return label
        }()
    
    // Вызов конструктора суперкласса с nil параметрами.
        init() { // Объявление инициализатора.
            super.init(nibName: nil, bundle: nil)
        }
        
        // Объявление обязательного инициализатора, который требуется, если вы используете Storyboards или XIBs. В этом случае он не реализован и вызовет ошибку выполнения.
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "TrackerWhite")
        navigationItem.leftBarButtonItem = addBarButtonItem
        
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerItem
        view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
    }
    
    @objc func addButtonTapped() {
            // Действие при нажатии на кнопку "+"
        }

}

