//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Александр Поляков on 03.09.2023.
//

enum SingleCategoryPageType {
    case create
    case edit(cat: TrackerCategory)
    
    private var interactor: TrackersCollectionsCompanionInteractor? {
            return TrackersCollectionsCompanionInteractor.shared
        }
    
    var title: String {
        switch self {
        case .create:
            return "Новая категория"
        case .edit:
            return "Редактирование категории"
        }
    }
    
    var completion: ((TrackerCategory) -> Void) {
            switch self {
            case .create:
                return { category in
                    self.interactor?.addCategory(name: category.categoryTitle)
                }
            case .edit(let cat):
                return { category in
                    self.interactor?.editCategory(category: cat, newName: category.categoryTitle)
                }
            }
        }
}


import Foundation
import UIKit
class NewCategoryViewController: UIViewController, UITextFieldDelegate {
    var clearButton = UIButton()
    var nameField: UISearchTextField = {
        let field = UISearchTextField()
        field.text = ""
        field.backgroundColor = UIColor(named: "TrackerSearchFieldColor")
        field.textColor = UIColor(named: "TrackerGray")
        return field
    }()
    var isTextFieldFocused: Bool = false
    
    var pageType: SingleCategoryPageType = .create
    var enteredName: String = ""
    
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
        checkSaveButtonReady()
        self.view.backgroundColor = UIColor(named: "TrackerWhite")
        self.navigationItem.hidesBackButton = true
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.title = pageType.title
        nameField.delegate = self
        nameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        setupUI()
        layoutUI()

    }
    
    func checkSaveButtonReady() {
        switch enteredName.count {
        case 0:
            addButton.isEnabled = false
            nameField.textColor = UIColor(named: "TrackerGray")
            addButton.backgroundColor = UIColor(named: "TrackerGray")
        default:
            addButton.isEnabled = true
            addButton.backgroundColor = UIColor(named: "TrackerBlack")
            nameField.textColor = UIColor(named: "TrackerBlack")
            print("КЕЙС ДЕФОЛТ")
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Настройка UITextField
        switch pageType {
            case .create:
            nameField.attributedPlaceholder = NSAttributedString(
                string: "Введите название трекера",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "TrackerGray")!]
            )
            case .edit(let cat):
                nameField.text = cat.categoryTitle
            }
        nameField.backgroundColor = UIColor(named: "TrackerBackground")
        
        nameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        nameField.clearButtonMode = .whileEditing
        if let crossImage = UIImage(named: "Cross") {
            nameField.rightView = UIImageView(image: crossImage)
            nameField.rightViewMode = .whileEditing
        }
        
        
        addButton.setTitle("Готово", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addButton.setTitleColor(UIColor(named: "TrackerWhite"), for: .normal)
        addButton.layer.cornerRadius = 16
        addButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        view.addSubview(nameField)
        view.addSubview(addButton)
        
    }
    
    // MARK: - Layout
    private func layoutUI() {
        
        nameField.translatesAutoresizingMaskIntoConstraints = false
        nameField.layer.cornerRadius = 16
        nameField.clipsToBounds = true
        nameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: nameField.frame.height))
        
        clearButton.setImage(UIImage(named: "Cross"), for: .normal)
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        nameField.rightView = clearButton
        configureForLocale()
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            nameField.heightAnchor.constraint(equalToConstant: 75),
            nameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

        ])
    }
    
    private func configureForLocale() {
        let isRightToLeft = view.effectiveUserInterfaceLayoutDirection == .rightToLeft
        
        if isRightToLeft {
            nameField.textAlignment = .right
            nameField.leftView = clearButton
            nameField.leftViewMode = .never
            nameField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: nameField.frame.height))
            nameField.rightViewMode = .always
            clearButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        } else {
            nameField.textAlignment = .left
            nameField.rightView = clearButton
            nameField.rightViewMode = .never
            nameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: nameField.frame.height))
            nameField.leftViewMode = .always
            clearButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        }
    }
    
    
    
    @objc func dismissKeyboard() {
        nameField.resignFirstResponder()
        isTextFieldFocused =  false
    }
    
    @objc func saveButtonTapped(_ sender: Any) {
        switch pageType {
        case .create:
            let category = TrackerCategory(id: UUID(), categoryTitle: enteredName)
            pageType.completion(category)
        case .edit(let cat):
            pageType.completion(cat)
        }
        delegate?.tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        isTextFieldFocused  = true
        enteredName = textField.text ?? ""

        checkSaveButtonReady()
    }
    
    @objc func clearTextField() {
        nameField.text = ""
        enteredName = ""
        checkSaveButtonReady()
    }
}
