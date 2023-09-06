import Foundation
import UIKit

final class CategorySelectionViewController: UIViewController {
    var delegate: TrackerTypeDelegate? = nil
    private var categories: [TrackerCategory]? = nil
    private var longtappedCategory: TrackerCategory? = nil
    var completionDone: ((TrackerCategory?) -> Void)? = nil
    
    private let viewModel = CategorySelectionViewModel()
    
    let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let voidImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "VoidImage")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    // Элементы UI
    let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
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
    
    var selectedIndex: Int? = nil
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "TrackerWhite")
        self.navigationItem.hidesBackButton = true
        self.title = "Категория"
        setupUI()
        layoutUI()
        bind()
        addButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        viewModel.updateState()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(addButton)
        view.addSubview(tableView)
        view.addSubview(voidImage)
        view.addSubview(questionLabel)
    }
    
    private func layoutUI() {
        NSLayoutConstraint.activate([
            
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -38),
            
            voidImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            voidImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            voidImage.widthAnchor.constraint(equalToConstant: 80),
            voidImage.heightAnchor.constraint(equalToConstant: 80),
            
            questionLabel.topAnchor.constraint(equalTo: voidImage.bottomAnchor, constant: 8),
            questionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            
        ])
        tableView.separatorStyle = .none
    }
    
    private func showStartingBlock() {
        voidImage.isHidden = false
        questionLabel.isHidden = false
    }
    
    private func hideStartingBlock() {
        voidImage.isHidden = true
        questionLabel.isHidden = true
    }
    
    func howMuchIsTheCategories() -> Int {
        return categories?.count ?? 0
    }
    
    func updateViewModel() {
        viewModel.updateState()
    }
    
    func setInteractionAtCategory(category: TrackerCategory) {
        guard let categories = categories else { return }
        print("Я ВЗАИМОДЕЙСТВУЮ С КАТЕГОРИЕЙ")
        for (index, cat) in categories.enumerated() {
            if cat.id == category.id {
                print(index)
                print(cat)
                viewModel.handleNavigation(action: .select(category: cat, pos: index))
            }
        }
    }
    
    
    
    private func bind() {
        viewModel.navigationClosure = { [weak self] in
            guard let self = self else { return }
            let state = self.viewModel.navigationState
            switch state {
            case .removeCategory:
                self.tableView.reloadData()
            case .addCategory:
                let newCategoryViewController = NewCategoryViewController()
                newCategoryViewController.delegate = self
                self.navigationController?.pushViewController(newCategoryViewController, animated: true)
            case .editcategory(let category):
                let editCategoryViewController = NewCategoryViewController()
                editCategoryViewController.pageType = .edit(cat: category)
                editCategoryViewController.delegate = self
                self.navigationController?.pushViewController(editCategoryViewController, animated: true)
            case .categoryApproved(let category):
                self.delegate?.didSelectTrackerCategory(category)
                self.completionDone?(category)
                self.navigationController?.popViewController(animated: true)
            case .categorySelected(_ , let position):
                var paths: [IndexPath] = []
                if  let previousPosition = self.selectedIndex {
                    paths.append(IndexPath(row: previousPosition, section: 0))
                }
                self.selectedIndex = position
                paths.append(IndexPath(row: position, section: 0))
                self.tableView.reloadRows(at: paths, with: .automatic)
            default:
                break
            }
        }
        
        viewModel.stateClosure = { [weak self] in
            guard let self = self else { return }
            let state = self.viewModel.state
            switch state {
            case .emptyResult:
                self.categories = nil
                self.showStartingBlock()
            case .showResult(let categories):
                self.categories = categories
                self.hideStartingBlock()
                self.tableView.reloadData()
            default:
                viewModel.updateState()
            }
            
            
        }
        
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CategorySelectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let quantity = categories?.count ?? 0
        return quantity
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableViewCell
        cell.backgroundColor = UIColor(named: "TrackerBackground")
        cell.layer.cornerRadius = 16
        cell.titleLabel.textColor = UIColor(named: "TrackerBlack")
        cell.checkmarkImageView.isHidden = true
        cell.targetCategory = categories?[indexPath.row]
        if let cat = cell.targetCategory?.categoryTitle {
            cell.textLabel?.text = cat
            
        }
        let quantity = categories?.count ?? 0
        if indexPath.row == quantity - 1 {
            cell.separatorView.isHidden = true
        } else {
            cell.separatorView.isHidden = false
        }
        
        roundCornersForCell(cell, in: tableView, at: indexPath)
        
        if let selectedIndex = selectedIndex {
            if indexPath.row == selectedIndex  {
                cell.checkmarkImageView.isHidden = false
            }
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
        return CategoryTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let categories = categories else { return }
        viewModel.handleNavigation(action: .select(category: categories[indexPath.row], pos: indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        longtappedCategory = categories?[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            let editAction = UIAction(title: "Редактировать", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off) { action in
                guard let longtappedCategory = self.longtappedCategory else { return }
                self.viewModel.handleNavigation(action: .edit(category: longtappedCategory))
            }
            
            let deleteAction = UIAction(title: "Удалить", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off) {action in
                guard let longtappedCategory = self.longtappedCategory else { return }
                self.viewModel.handleNavigation(action: .remove(category: longtappedCategory))
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    @objc func addCategory() {
        let newCategoryViewController = NewCategoryViewController()
        newCategoryViewController.delegate = self
        self.navigationController?.pushViewController(newCategoryViewController, animated: true)
    }
}

enum InteractionType {
    case add
    case edit(category: TrackerCategory)
    case remove(category: TrackerCategory)
    case select(category: TrackerCategory, pos: Int)
}



