import Foundation
import UIKit

final class FiltersTrackerViewController: UIViewController {
    
    var delegate: FilterDelegate? =  nil
    private let viewModel = FiltersTrackerViewModel()
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    init (filterSelected: TrackerPredicateType? = nil) {
        super.init(nibName: nil, bundle: nil)
        guard let filter = filterSelected else { return }
        viewModel.setFilterSelected(filter)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "TrackerWhite")
        self.navigationItem.hidesBackButton = true
        self.title = L10n.filter
        view.addSubview(tableView)
        layoutUI()
        bind()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "FilterCell")
        viewModel.refreshState()
    }
    
    private func layoutUI() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -38)
        ])
        tableView.separatorStyle = .none
    }
   
    func howMuchIsTheFilters() -> Int {
        return viewModel.howManyFilters()
    }
    
    func updateViewModel() {
        viewModel.refreshState()
    }
    
    private func bind() {
        
        viewModel.navigationClosure = { [weak self] in
            guard let self = self else { return }
            let state = self.viewModel.navigationState
            switch state {
            case .filterApproved(let filterPack):
                self.delegate?.applyFilters(type: filterPack.predicate)
                self.navigationController?.popViewController(animated: true)
            default:
                break
            }
        }
        
        viewModel.stateClosure = { [weak self] in
            guard let self = self else { return }
            let state = self.viewModel.state
            switch state {
            case .show(_, let paths):
                guard let paths = paths else { self.tableView.reloadData() ; return }
                let indexPaths = paths.map { IndexPath(row: $0, section: 0) }
                self.tableView.reloadRows(at: indexPaths, with: .automatic)
            default:
                viewModel.refreshState()
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension FiltersTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.howManyFilters()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! CategoryTableViewCell
        cell.backgroundColor = UIColor(named: "TrackerBackground")
        cell.layer.cornerRadius = 16
        cell.titleLabel.textColor = UIColor(named: "TrackerBlack")
        cell.checkmarkImageView.isHidden = true
        guard let filter = viewModel.giveMeFilter(pos: indexPath.row) else { return cell }
        cell.textLabel?.text = filter.title
        let quantity = viewModel.howManyFilters()
        if indexPath.row == quantity - 1 {
            cell.separatorView.isHidden = true
        } else {
            cell.separatorView.isHidden = false
        }
        roundCornersForCell(cell, in: tableView, at: indexPath)
        cell.checkmarkImageView.isHidden = viewModel.isNotCheckedFilter(pos: indexPath.row)
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
        return CategoryTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.handleTap(pos: indexPath.row)
    }
}
