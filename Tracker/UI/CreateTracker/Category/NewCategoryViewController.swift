//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Александр Поляков on 03.09.2023.
//

import Foundation
import UIKit
class NewCategoryViewController: UIViewController, UITextFieldDelegate {
    
    var nameField: UISearchTextField = {
        let field = UISearchTextField()
        field.text = "Введите название категории"
        field.backgroundColor = UIColor(named: "TrackerSearchFieldColor")
        field.textColor = UIColor(named: "TrackerGray")
        return field
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
    
    weak var delegate: CategorySelectionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.delegate = self
        nameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        addButton.isEnabled = false
        addButton.alpha = 0.5
    }
    
    @objc func saveButtonTapped(_ sender: Any) {
        delegate?.addCategory()
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if nameField.text != "" {
            addButton.isEnabled = true
            addButton.alpha = 1
            delegate?.selectedCategory = TrackerCategory(id: UUID(), categoryTitle: nameField.text ?? "")
        } else {
            addButton.isEnabled = false
            addButton.alpha = 0.5
        }
    }
}
