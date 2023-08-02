//
//  ViewController.swift
//  Tracker
//
//  Created by Александр Поляков on 27.07.2023.
//

import UIKit

class TrackersViewController: UIViewController, UITextFieldDelegate {
    
    let addBarButtonItem: UIBarButtonItem = {
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: "Add"), for: .normal)
        
        button.addTarget(TrackersViewController.self, action: #selector(addButtonTapped), for: .touchUpInside)
            let barButtonItem = UIBarButtonItem(customView: button)
            return barButtonItem
        
        }()

        let datePicker: UIDatePicker = {
            let picker = UIDatePicker()
            picker.preferredDatePickerStyle = .compact
            picker.datePickerMode = .date
            return picker
        }()
    
    let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "Трекеры"
            label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
            return label
        }()
    
    let questionLabel: UILabel = {
            let label = UILabel()
            label.text = "Что будем отслеживать?"
            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            return label
        }()
    
    let VoidImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "VoidImage")
        return image
    }()
    
    var searchField: UISearchTextField = {
        let field = UISearchTextField()
        field.text = "Поиск"
        field.textColor = UIColor(named: "TrackerGray")
        return field
    }()
    
    // Вызов конструктора суперкласса с nil параметрами.
        init() { // Объявление инициализатора.
            super.init(nibName: nil, bundle: nil)
        }
        
        // Объявление обязательного инициализатора, который требуется, если вы используете Storyboards или XIBs. В этом случае он не реализован и вызовет ошибку выполнения.
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "TrackerWhite")
        navigationItem.leftBarButtonItem = addBarButtonItem
        searchField.delegate = self
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerItem
        view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        view.addSubview(searchField)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(VoidImage)
        VoidImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            VoidImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            VoidImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            VoidImage.widthAnchor.constraint(equalToConstant: 80),
            VoidImage.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        view.addSubview(questionLabel)
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: VoidImage.bottomAnchor, constant: 8),
            questionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func addButtonTapped() {
            // Действие при нажатии на кнопку "+"
        }

}

