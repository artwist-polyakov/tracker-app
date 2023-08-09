import Foundation
import UIKit
class CreateTrackerViewController: UIViewController {
    private var didDataCollected: NSObjectProtocol?
    private var didDataNotCollected: NSObjectProtocol?
    weak var delegate: TrackerTypeDelegate?
    var clearButton = UIButton()
    let cancelButton = UIButton()
    let createButton = UIButton()
    var shedule: Set<String> = []
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
    init() {
        let layout = UICollectionViewFlowLayout()
        iconCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCreateButtonReady() 
        self.view.backgroundColor = .white
        self.navigationItem.hidesBackButton = true
        delegate?.didSelectTrackerCategory((delegate?.giveMeSelectedCategory().id)!)
        setupUI()
        layoutUI()
        menuTableView.reloadData()
        self.view.layoutIfNeeded()
        
        didDataCollected = NotificationCenter.default.addObserver(
                    forName: TrackersCollectionsPresenter.DidReadyNotification,
                    object: nil,
                    queue: .main
                ) { [weak self] _ in
                    guard let self = self
                    else { return }
                    print("ПОЛУЧИЛ УВЕДОМЛЕНИЕ ЧТО ДАННЫЕ ГОТОВЫ")
                    checkCreateButtonReady()
                }
        
        didDataNotCollected = NotificationCenter.default.addObserver(
                    forName: TrackersCollectionsPresenter.DidNotReadyNotification,
                    object: nil,
                    queue: .main
                ) { [weak self] _ in
                    guard let self = self
                    else { return }
                    print("ПОЛУЧИЛ УВЕДОМЛЕНИЕ ЧТО ДАННЫЕ НЕ ГОТОВЫ")
                    checkCreateButtonReady()
                }
        
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
        colorCollectionView.frame.size.width = view.bounds.width
        menuItems = [
            MenuItem(title: "Выбрать категорию", subtitle: delegate?.giveMeSelectedCategory().categoryTitle ?? "", action: handleSelectCategory),
            MenuItem(title: "Создать расписание", subtitle: Mappers.sortedStringOfSetWeekdays(shedule), action: handleCreateSchedule)
                ]
                
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.isScrollEnabled = false
        menuTableView.register(MenuTableViewCell.self, forCellReuseIdentifier: "MenuCell")
        menuTableView.register(IconCollectionViewCell.self, forCellReuseIdentifier: "IconCollectionViewCell")
        menuTableView.register(ColorCollectionViewCell.self, forCellReuseIdentifier: "ColorCollectionViewCell")
        menuTableView.isScrollEnabled = true
        view.addSubview(menuTableView)
        
        // Настройка cancelButton
        cancelButton.backgroundColor = .white
        cancelButton.layer.borderColor = UIColor(named: "TrackerRed")?.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.setTitle("Отмена", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(UIColor(named: "TrackerRed"), for: .normal)
        cancelButton.layer.cornerRadius = 16
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        // Настройка createButton
        createButton.setTitle("Создать", for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.backgroundColor = UIColor(named: "TrackerGray")
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 16
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        view.addSubview(createButton)
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
    
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
            
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
        
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

        menuTableView.backgroundColor = UIColor(named: "TrackerWhite")
        menuTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        menuTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        menuTableView.translatesAutoresizingMaskIntoConstraints = false
        menuTableView.separatorStyle = .none
        
        NSLayoutConstraint.activate([
            menuTableView.topAnchor.constraint(equalTo: trackerNameField.bottomAnchor, constant: 20),
            menuTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            menuTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            menuTableView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16)
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
            clearButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        } else {
            trackerNameField.textAlignment = .left
            trackerNameField.rightView = clearButton
            trackerNameField.rightViewMode = .never
            trackerNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: trackerNameField.frame.height))
            trackerNameField.leftViewMode = .always
            clearButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        }
    }
    
    func checkCreateButtonReady() {
        if (warningLabel.isHidden) && (delegate?.isReadyToFlush() ?? false) {
            createButton.isEnabled = true
            createButton.backgroundColor = UIColor(named: "TrackerBlack")
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = UIColor(named: "TrackerGray")
        }
    }
    
    func changeSheduleMenuSubtitle(_ newTitle:String){
        menuTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
    }
    
    // MARK: - Actions
    private func handleSelectCategory() {
        // Переход к экрану выбора категории
    }
    
    private func handleCreateSchedule() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.daysChecked = self.shedule
        let weekdaysDictionary = Mappers.giveMeAllWeekdaysNames()
        scheduleVC.content = weekdaysDictionary.keys.map { $0.localizedCapitalized }
        scheduleVC.content.sort(by: { weekdaysDictionary[$0.lowercased()]! < weekdaysDictionary[$1.lowercased()]! })
        scheduleVC.completionDone = {
            self.delegate?.didSetShedulleToFlush(scheduleVC.daysChecked)
            self.shedule = scheduleVC.daysChecked
            let newSubtitle = Mappers.sortedStringOfSetWeekdays(self.shedule)
            self.menuItems[1].subtitle = newSubtitle
            self.changeSheduleMenuSubtitle(newSubtitle)
        }
        self.navigationController?.pushViewController(scheduleVC, animated: true)
    }

    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.isEmpty == false {
            textField.textColor = UIColor(named: "TrackerBlack")
            textField.rightViewMode = .always
            if textField.text?.count ?? 0 <= 38 {
                warningLabel.isHidden = true
                delegate?.didSetTrackerTitle(textField.text ?? "")
            } else {
                warningLabel.isHidden = false
            }
        } else {
            textField.textColor = UIColor(named: "TrackerGray")
            textField.rightViewMode = .never
            warningLabel.isHidden = true
        }
    }
    
    @objc func clearTextField() {
        trackerNameField.text = ""
        textFieldDidChange(trackerNameField)
//        checkCreateButtonReady()
    }
    
    @objc func cancelButtonTapped() {
        delegate?.clearAllFlushProperties()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func createButtonTapped() {
        delegate?.realizeAllFlushProperties()
        self.dismiss(animated: true, completion: nil)
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
        case .notSet:
            titleLabel.text = "Неизвестный лейбл"
        }
    }

}

// MARK: UITableViewDataSource, UITableViewDelegate
extension CreateTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("вызван numberOfRowsInSection для \(section)")
        switch section {
        case 0:
            return menuItems.count
        case 1, 2:
            return 1
        default:
            return 0
        }
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("numberOfSections вызван")
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuTableViewCell
            let menuItem = menuItems[indexPath.row]
            cell.titleLabel.text = menuItem.title
            cell.backgroundColor = UIColor(named: "TrackerBackground")
            cell.layer.cornerRadius = 16
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
            roundCornersForCell(cell, in: tableView, at: indexPath)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IconCollectionViewCell", for: indexPath) as! IconCollectionViewCell
            cell.delegate = self.delegate
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCollectionViewCell", for: indexPath) as! ColorCollectionViewCell
            cell.delegate = self.delegate
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
            print("heightForRowAt вызван для \(indexPath.section)")
            return 204 // высота для коллекций
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 { // Добавьте отступ после первой секции
            return 32
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView() // Возвращает пустое представление
    }
    
    func roundCornersForCell(_ cell: UITableViewCell, in tableView: UITableView, at indexPath: IndexPath) {
        cell.layer.cornerRadius = 0 // reset corner radius
        cell.clipsToBounds = false
        
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)
        if indexPath.row == 0 && totalRows == 1 {
            // Если в секции всего одна ячейка
            cell.layer.cornerRadius = 16
        } else if indexPath.row == 0 {
            // Если это первая ячейка
            cell.roundCorners([.topLeft, .topRight], radius: 16)
        } else if indexPath.row == totalRows - 1 {
            // Если это последняя ячейка
            cell.roundCorners([.bottomLeft, .bottomRight], radius: 16)
        }
    }
    

}

