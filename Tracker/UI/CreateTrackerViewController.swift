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
    
    let warningLabel: UILabel = {
            let label = UILabel()
            label.text = "Ограничение 38 символов"
            label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            label.textColor = UIColor(named: "TrackerRed")
            label.textAlignment = .center
            label.isHidden = true
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
    
    let trackerNameField = UITextField()
    var iconCollectionView: UICollectionView
    var colorCollectionView: UICollectionView
    let menuTableView = UITableView()
    var menuItems: [MenuItem] = []
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
        menuTableView.reloadData()
    }
    
    // MARK: - UI Setup
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
        
        iconCollectionView.register(IconCell.self, forCellWithReuseIdentifier: "IconCell")
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        
        // Настройка коллекции иконок
        iconCollectionView.dataSource = self
        iconCollectionView.delegate = self
        iconCollectionView.register(IconCell.self, forCellWithReuseIdentifier: "IconCell")
        iconCollectionView.backgroundColor = .lightGray
        // Настройка коллекции цветов
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        
        iconCollectionView.reloadData()
        colorCollectionView.reloadData()
        
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        iconCollectionView.isScrollEnabled = false
        colorCollectionView.isScrollEnabled = false
        iconCollectionView.frame.size.width = view.bounds.width
        colorCollectionView.frame.size.width = view.bounds.width
        menuItems = [
                    MenuItem(title: "Выбрать категорию", subtitle: "Важное", action: handleSelectCategory),
                    MenuItem(title: "Создать расписание", subtitle: "", action: handleCreateSchedule)
                ]
                
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.isScrollEnabled = false
        menuTableView.layer.cornerRadius = 16
        menuTableView.register(MenuTableViewCell.self, forCellReuseIdentifier: "MenuCell")
        menuTableView.register(CollectionTableViewCell.self, forCellReuseIdentifier: "CollectionCell")
        view.addSubview(menuTableView)
//        view.addSubview(iconCollectionView)
//        iconCollectionView.frame = CGRect(x: 0, y: 100, width: view.bounds.width, height: 200)
    }
    
    // MARK: - Layout
    private func layoutUI() {
        
        view.addSubview(titleLabel)
        view.addSubview(trackerNameField)
        view.addSubview(warningLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerNameField.translatesAutoresizingMaskIntoConstraints = false

        trackerNameField.layer.cornerRadius = 16
        trackerNameField.clipsToBounds = true
        trackerNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: trackerNameField.frame.height))

        
        
        clearButton.setImage(UIImage(named: "Cross"), for: .normal)
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        trackerNameField.rightView = clearButton
        configureForLocale()
        
        iconCollectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        colorCollectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")

        
        NSLayoutConstraint.activate([
            
            
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            trackerNameField.heightAnchor.constraint(equalToConstant: 75),
            trackerNameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            trackerNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            trackerNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            warningLabel.topAnchor.constraint(equalTo: trackerNameField.bottomAnchor, constant: 8),
            warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

        ])

        menuTableView.backgroundColor = UIColor(named: "TrackerBackground")
        menuTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        menuTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        menuTableView.translatesAutoresizingMaskIntoConstraints = false
        menuTableView.separatorStyle = .none
        NSLayoutConstraint.activate([
            menuTableView.topAnchor.constraint(equalTo: trackerNameField.bottomAnchor, constant: 20),
            menuTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            menuTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            menuTableView.heightAnchor.constraint(equalToConstant: MenuTableViewCell.cellHeight * CGFloat(menuItems.count)),
            


        ])
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
    
    // MARK: - Actions
    private func handleSelectCategory() {
        // Переход к экрану выбора категории
    }
    
    private func handleCreateSchedule() {
        // Переход к экрану создания расписания
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.isEmpty == false {
            textField.textColor = UIColor(named: "TrackerBlack")
            textField.rightViewMode = .always
            warningLabel.isHidden = textField.text?.count ?? 0 <= 38
        } else {
            textField.textColor = UIColor(named: "TrackerGray")
            textField.rightViewMode = .never
            warningLabel.isHidden = true
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
//            createScheduleButton.isEnabled = true
            titleLabel.text = "Новая привычка"
        case .irregularEvent:
//            createScheduleButton.isEnabled = false
            titleLabel.text = "Новое нерегулярное событие"
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! SupplementaryView
            
            if collectionView == iconCollectionView {
                header.titleLabel.text = "Emoji"
            } else if collectionView == colorCollectionView {
                header.titleLabel.text = "Цвет"
            }
            
            return header
        default:
            assert(false, "Invalid element type")
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == iconCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCell", for: indexPath) as! IconCell
            cell.label.text = icons[indexPath.row]
            return cell
        } else if collectionView == colorCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
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

extension CreateTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return menuItems.count
        case 1, 2:
            return 18 // по одной 18 для каждой коллекции
        default:
            return 0
        }
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 204 // высота для iconCollectionView
        } else if section == 2 {
            return 204 // высота для colorCollectionView
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuTableViewCell
            let menuItem = menuItems[indexPath.row]
            cell.titleLabel.text = menuItem.title
            
            if selectedTrackerType == .irregularEvent && indexPath.row == 1 {
                cell.isUserInteractionEnabled = false
                cell.titleLabel.textColor = .gray
            } else {
                cell.isUserInteractionEnabled = true
                cell.titleLabel.textColor = UIColor(named: "TrackerBlack")
            }
            
            cell.subtitleLabel.text = menuItem.subtitle
            if menuItem.subtitle.isEmpty {
                cell.subtitleLabel.isHidden = true
            } else {
                cell.subtitleLabel.isHidden = false
            }
            
            if indexPath.row == menuItems.count - 1 {
                cell.separatorView.isHidden = true
            } else {
                cell.separatorView.isHidden = false
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! CollectionTableViewCell
            cell.collectionView = iconCollectionView
            cell.collectionView.dataSource = self
            cell.collectionView.delegate = self
            cell.collectionView.reloadData()
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! CollectionTableViewCell
            cell.collectionView = colorCollectionView
            cell.collectionView.reloadData()
            return cell

            default:
                return UITableViewCell()
            }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedTrackerType == .irregularEvent && indexPath.row == 1 {
            return
        }
        menuItems[indexPath.row].action()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return MenuTableViewCell.cellHeight
        case 1, 2:
            return 204 // высота для коллекций
        default:
            return 0
        }
    }
}

extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == iconCollectionView {
            return CGSize(width: 50, height: 50)
        } else if collectionView == colorCollectionView {
            return CGSize(width: 50, height: 50)
        }
        return CGSize(width: 50, height: 50)
    }

    
    
}
