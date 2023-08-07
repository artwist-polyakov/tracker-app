//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Александр Поляков on 06.08.2023.
//

import Foundation
import UIKit
class CreateTrackerViewController: UIViewController {
    
    weak var delegate: TrackerTypeDelegate?
    
    var clearButton = UIButton()
    
    var selectedTrackerType: TrackerType? {
        didSet {
            configureForSelectedType()
        }
    }
    
    // Элементы UI
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "TrackerBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let trackerNameField = UITextField()
    let selectCategoryButton = UIButton(type: .system)
    let createScheduleButton = UIButton(type: .system)
    let iconCollectionView: UICollectionView
    let colorCollectionView: UICollectionView
    
    // Данные для коллекции иконок и цветов
    let icons: [String] = ["🙂", "🤩", "😍", "🥳", "😎", "😴", "😤", "😡", "🥺", "🤔", "🤨", "🙃", "😇", "😂", "🤣", "😅", "😆", "😁"] // Можно добавить или изменить иконки
    let colors: [UIColor] = (1...18).compactMap { UIColor(named: "\($0)") }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        iconCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.hidesBackButton = true
        setupUI()
        layoutUI()
    }
    
    private func setupUI() {
        // Настройка UITextField
        trackerNameField.placeholder = "Имя трекера"
        trackerNameField.backgroundColor = UIColor(named: "TrackerBackground")
        trackerNameField.attributedPlaceholder = NSAttributedString(
                string: "Введите название трекера",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "TrackerGray")!]
            )
        trackerNameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        trackerNameField.clearButtonMode = .whileEditing
            if let crossImage = UIImage(named: "Cross") {
                trackerNameField.rightView = UIImageView(image: crossImage)
                trackerNameField.rightViewMode = .whileEditing
            }
        
        
        titleLabel.textAlignment = .center
        
        // Настройка кнопки выбора категории
        selectCategoryButton.setTitle("Выбрать категорию", for: .normal)
        selectCategoryButton.addTarget(self, action: #selector(handleSelectCategory), for: .touchUpInside)
        
        // Настройка кнопки создания расписания
        createScheduleButton.setTitle("Создать расписание", for: .normal)
        createScheduleButton.addTarget(self, action: #selector(handleCreateSchedule), for: .touchUpInside)
        
        // Настройка коллекции иконок
        iconCollectionView.dataSource = self
        iconCollectionView.delegate = self
        iconCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "IconCell")
        
        // Настройка коллекции цветов
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")
    }
    
    private func layoutUI() {
        
        view.addSubview(titleLabel)
        view.addSubview(trackerNameField)
        view.addSubview(selectCategoryButton)
        view.addSubview(createScheduleButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerNameField.translatesAutoresizingMaskIntoConstraints = false
        selectCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        createScheduleButton.translatesAutoresizingMaskIntoConstraints = false
        trackerNameField.layer.cornerRadius = 16
        trackerNameField.clipsToBounds = true
        trackerNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: trackerNameField.frame.height))

        
        
        clearButton.setImage(UIImage(named: "Cross"), for: .normal)
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        trackerNameField.rightView = clearButton


        configureForLocale()
        
        NSLayoutConstraint.activate([
            
            
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            trackerNameField.heightAnchor.constraint(equalToConstant: 75),
            trackerNameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            trackerNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            trackerNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            selectCategoryButton.topAnchor.constraint(equalTo: trackerNameField.bottomAnchor, constant: 20),
            selectCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectCategoryButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),

            createScheduleButton.topAnchor.constraint(equalTo: trackerNameField.bottomAnchor, constant: 20),
            createScheduleButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            createScheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func handleSelectCategory() {
        // Переход к экрану выбора категории
    }
    
    @objc private func handleCreateSchedule() {
        // Переход к экрану создания расписания
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.isEmpty == false {
                textField.textColor = UIColor(named: "TrackerBlack")
                textField.rightViewMode = .always
        } else {
            textField.textColor = UIColor(named: "TrackerGray")
            textField.rightViewMode = .never
        }
    }
    
    @objc func clearTextField() {
        trackerNameField.text = ""
        textFieldDidChange(trackerNameField)
    }
    
    private func configureForSelectedType() {
        guard let type = selectedTrackerType else { return }
        
        switch type {
        case .habit:
            createScheduleButton.isEnabled = true
            titleLabel.text = "Новая привычка"
        case .irregularEvent:
            createScheduleButton.isEnabled = false
            titleLabel.text = "Новое нерегулярное событие"
        }
    }
    
    private func configureForLocale() {
        let isRightToLeft = view.effectiveUserInterfaceLayoutDirection == .rightToLeft

        if isRightToLeft {
            trackerNameField.textAlignment = .right
            trackerNameField.leftView = clearButton
            trackerNameField.leftViewMode = .never
            trackerNameField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: trackerNameField.frame.height))
            trackerNameField.rightViewMode = .always
            
            // отступ для clearButton
            clearButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        } else {
            trackerNameField.textAlignment = .left
            trackerNameField.rightView = clearButton
            trackerNameField.rightViewMode = .never
            trackerNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: trackerNameField.frame.height))
            trackerNameField.leftViewMode = .always

            // отступ для clearButton
            clearButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        }
    }

}

// Расширение для работы с коллекциями
extension CreateTrackerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == iconCollectionView {
            return icons.count
        } else if collectionView == colorCollectionView {
            return colors.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == iconCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCell", for: indexPath)
            let label = UILabel(frame: cell.bounds)
            label.text = icons[indexPath.row]
            label.textAlignment = .center
            cell.contentView.addSubview(label)
            return cell
        } else if collectionView == colorCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
            cell.backgroundColor = colors[indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == iconCollectionView {
            // Здесь обработать выбор иконки
        } else if collectionView == colorCollectionView {
            // Здесь обработать выбор цвета
        }
    }
}
