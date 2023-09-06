import Foundation
import UIKit

final class CategorySelectionViewController: UIViewController {
    var delegate: TrackerTypeDelegate? = nil
    var selectedCategory: TrackerCategory? {
        didSet {
            tableView.reloadData()
            guard let delegate = delegate,
                  let selectedCategory = selectedCategory else {return}
            delegate.didSelectTrackerCategory(selectedCategory.id)
        }
    }
    
    var longtappedCategory: TrackerCategory? = nil
    
    let interactor = TrackersCollectionsCompanionInteractor.shared

    let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
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
    
    var categoryChecked: TrackerCategory? = nil
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "TrackerWhite")
        self.navigationItem.hidesBackButton = true
        self.title = "Категория"
        
        
        setupUI()
        layoutUI()
        
        addButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "CategoryCell")
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
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -38)
        ])
    }
    
    func showStartingBlock() {
        voidImage.isHidden = false
        questionLabel.isHidden = false
    }
    
    func hideStartingBlock() {
        voidImage.isHidden = true
        questionLabel.isHidden = true
    }
    
    
    

}
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
extension CategorySelectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let quantity = interactor.giveMeAllCategories()?.count ?? 0
        quantity == 0 ? showStartingBlock() : hideStartingBlock()
        return quantity
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableViewCell
        cell.backgroundColor = UIColor(named: "TrackerBackground")
        cell.layer.cornerRadius = 16
        cell.titleLabel.textColor = UIColor(named: "TrackerBlack")
        cell.checkmarkImageView.isHidden = true
        cell.targetCategory = interactor.giveMeAllCategories()?[indexPath.row]
        if let cat = cell.targetCategory?.categoryTitle {
            cell.textLabel?.text = cat
        
        }
        let quantity = interactor.giveMeAllCategories()?.count ?? 0
        if indexPath.row == quantity - 1 {
            cell.separatorView.isHidden = true
        } else {
            cell.separatorView.isHidden = false
        }
        
        roundCornersForCell(cell, in: tableView, at: indexPath)
        
        if let selectedCategory = selectedCategory {
            if cell.targetCategory?.id == selectedCategory.id {
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
        if selectedCategory?.id != interactor.giveMeAllCategories()?[indexPath.row].id {
            selectedCategory = interactor.giveMeAllCategories()?[indexPath.row]
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        longtappedCategory = interactor.giveMeAllCategories()?[indexPath.row]
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
                let editAction = UIAction(title: "Редактировать", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off) { action in
                    guard let longtappedCategory = self.longtappedCategory else { return }
                    let editCategoryViewController = NewCategoryViewController()
                    editCategoryViewController.pageType = .edit(cat: longtappedCategory)
                    editCategoryViewController.delegate = self
                    
                    self.navigationController?.pushViewController(editCategoryViewController, animated: true)
                    print("Редактировать кнопка была нажата")
                }
                
                let deleteAction = UIAction(title: "Удалить", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off) { [weak self] action in

                    self?.removeCategory()
                }
                
                return UIMenu(title: "", children: [editAction, deleteAction])
            }
        }

    @objc func addCategory() {
        let newCategoryViewController = NewCategoryViewController()
        newCategoryViewController.delegate = self
        self.navigationController?.pushViewController(newCategoryViewController, animated: true)
    }
    
    @objc func removeCategory() {
        if let category = longtappedCategory {
            interactor.removeCategory(category: category)
            selectedCategory = nil
            tableView.reloadData()
        }
    }
    
}


