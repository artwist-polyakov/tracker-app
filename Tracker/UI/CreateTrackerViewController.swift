//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Александр Поляков on 06.08.2023.
//

import Foundation
import UIKit
class CreateTrackerViewController: UIViewController {
    
    // Элементы UI
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
        
        setupUI()
        layoutUI()
    }
    
    private func setupUI() {
        // Настройка UITextField
        trackerNameField.placeholder = "Имя трекера"
        
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
        // Здесь добавьте код для размещения элементов на экране, возможно, с использованием AutoLayout
    }
    
    @objc private func handleSelectCategory() {
        // Переход к экрану выбора категории
    }
    
    @objc private func handleCreateSchedule() {
        // Переход к экрану создания расписания
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
            // Здесь вы можете обработать выбор иконки
        } else if collectionView == colorCollectionView {
            // Здесь вы можете обработать выбор цвета
        }
    }
}
