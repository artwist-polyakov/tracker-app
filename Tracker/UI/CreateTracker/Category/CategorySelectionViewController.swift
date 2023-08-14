//
//  CategorySelectionViewController.swift
//  Tracker
//
//  Created by Александр Поляков on 06.08.2023.
//

import Foundation
import UIKit

class CategorySelectionViewController: UITableViewController {
    
    var categories: [TrackerCategory]
    var selectedCategory: TrackerCategory?
    let repository: TrackersRepositoryProtocol
    
    init(categories: [TrackerCategory], repository: TrackersRepositoryProtocol) {
        self.categories = categories
        self.repository = repository
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        title = "Выбор категории"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Добавить", style: .plain, target: self, action: #selector(addCategory))
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].categoryTitle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row]
        navigationController?.popViewController(animated: true)
    }
    
    @objc func addCategory() {
        let alert = UIAlertController(title: "Добавить категорию", message: "Введите имя новой категории", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Имя категории"
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Добавить", style: .default, handler: { [weak self] (_) in
            if let categoryName = alert.textFields?.first?.text, !categoryName.isEmpty {
                self?.repository.addNewCategory(name: categoryName)
                self?.categories = self?.repository.getAllTrackers() ?? []
                self?.tableView.reloadData()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
}

