import UIKit

final class ScheduleViewController: UIViewController {
    
    var daysChecked: Set<String> = []
    // MARK: - Properties
    var completionTurnOff: ((String) -> Void)?
    var completionTurnOn: ((String) -> Void)?
    var completionDone: (() -> Void)?
    var content: [String] = []
    
    // Элементы UI
    let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle(L10n.ready, for: .normal)
        button.backgroundColor = UIColor(named: "TrackerBlack")
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        button.setTitleColor(UIColor(named: "TrackerWhite"), for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "TrackerWhite")
        self.navigationItem.hidesBackButton = true
        self.title = L10n.Trackers.shedule
        completionTurnOff = { [weak self] it in
            print("ОШИБКА \(it)")
            self?.daysChecked.remove(it)
        }
        
        completionTurnOn = { [weak self] it in
            print("ОШИБКА \(it)")
            self?.daysChecked.insert(it)
        }
        
        
        
        
        setupUI()
        layoutUI()
        
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(SheduleTableViewCell.self, forCellReuseIdentifier: "MenuCell")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(doneButton)
        view.addSubview(tableView)
    }
    
    // MARK: - Layout
    private func layoutUI() {
        NSLayoutConstraint.activate([
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -38)
        ])
    }
    
    // MARK: - Actions
    @objc func doneButtonTapped() {
        completionDone?()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! SheduleTableViewCell
        cell.titleLabel.text = content[indexPath.row]
        cell.backgroundColor = UIColor(named: "TrackerBackground")
        cell.layer.cornerRadius = 16
        cell.titleLabel.textColor = UIColor(named: "TrackerBlack")
        cell.completionTurnOff = self.completionTurnOff
        cell.targetDay = content[indexPath.row]
        
        cell.completionTurnOn = self.completionTurnOn
        if indexPath.row == content.count - 1 {
            cell.separatorView.isHidden = true
        } else {
            cell.separatorView.isHidden = false
        }
        roundCornersForCell(cell, in: tableView, at: indexPath)
        
        if daysChecked.contains(content[indexPath.row]) {
            cell.switchControl.isOn = true
        } else {
            cell.switchControl.isOn = false
        }
        return cell
    }
    
    func roundCornersForCell(_ cell: UITableViewCell, in tableView: UITableView, at indexPath: IndexPath) {
        cell.layer.cornerRadius = 0
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SheduleTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SheduleTableViewCell {
            cell.switchControl.isOn.toggle()
            cell.switchValueChanged(cell.switchControl)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


