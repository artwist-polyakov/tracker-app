import Foundation
import UIKit

final class CategorySelectionViewController: UIViewController {
    
    var selectedCategory: TrackerCategory?
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
    
    // MARK: - Table view data source
extension CategorySelectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let quantity = interactor.giveMeAllCategories()?.count ?? 0
        quantity == 0 ? showStartingBlock() : hideStartingBlock()
        return quantity
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = interactor.giveMeAllCategories()?[indexPath.row].categoryTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = interactor.giveMeAllCategories()?[indexPath.row]
        navigationController?.popViewController(animated: true)
    }
    
    @objc func addCategory() {
        
        let newCategoryViewController = NewCategoryViewController()
        self.navigationController?.pushViewController(newCategoryViewController, animated: true)
    }
}


