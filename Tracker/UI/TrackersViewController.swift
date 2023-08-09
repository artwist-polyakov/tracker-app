//
//  ViewController.swift
//  Tracker
//
//  Created by Александр Поляков on 27.07.2023.
//

import UIKit

class TrackersViewController: UIViewController {
    
    var addBarButtonItem: UIBarButtonItem?
    var collectionView: UICollectionView?
    var collectionPresenter: TrackersCollectionsPresenter!
    var collectionCompanion: TrackersCollectionsCompanion?
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        return picker
        }()
    
    let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "Трекеры"
            label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
            return label
        }()
    
    let questionLabel: UILabel = {
            let label = UILabel()
            label.text = "Что будем отслеживать?"
            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            return label
        }()
    
    let VoidImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "VoidImage")
        return image
    }()
    
    var searchField: UISearchTextField = {
        let field = UISearchTextField()
        field.text = "Поиск"
        field.textColor = UIColor(named: "TrackerGray")
        return field
    }()
    
    // Вызов конструктора суперкласса с nil параметрами.
        init() { // Объявление инициализатора.
            super.init(nibName: nil, bundle: nil)
        }
        
        // Объявление обязательного инициализатора, который требуется, если вы используете Storyboards или XIBs. В этом случае он не реализован и вызовет ошибку выполнения.
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionPresenter = TrackersCollectionsPresenter(vc: self)
        collectionCompanion = TrackersCollectionsCompanion(vc: self, delegate: collectionPresenter)
        collectionPresenter.selectedDate = self.datePicker.date
        view.backgroundColor = UIColor(named: "TrackerWhite")
        
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.dataSource = collectionCompanion
        collectionView?.delegate = collectionCompanion
        collectionView?.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCollectionViewCell")
        collectionView?.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        
        view.addSubview(collectionView!)
        
        setupButtons()
        navigationItem.leftBarButtonItem = addBarButtonItem
        searchField.delegate = self
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerItem
        view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        view.addSubview(searchField)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(VoidImage)
        VoidImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            VoidImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            VoidImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            VoidImage.widthAnchor.constraint(equalToConstant: 80),
            VoidImage.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        view.addSubview(questionLabel)
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: VoidImage.bottomAnchor, constant: 8),
            questionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView!.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 16),
            collectionView!.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView!.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView!.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func addButtonTapped() {
        let trackerTypeViewController = TrackerTypeViewController()
        trackerTypeViewController.delegate = collectionPresenter
        let navigationController = UINavigationController(rootViewController: trackerTypeViewController)
        self.present(navigationController, animated: true, completion: nil)
        }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        collectionPresenter.selectedDate = sender.date
        collectionCompanion?.selectedDate = sender.date
        print("Новая дата: \(sender.date)")
        collectionView?.reloadData()
    }
    
    func setupButtons() {
        addBarButtonItem = {
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: "Add"), for: .normal)
        
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
            let barButtonItem = UIBarButtonItem(customView: button)
            return barButtonItem
        
        }()
    }

}

extension TrackersViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        textField.textColor = UIColor(named: "TrackerBlack")
    }
}


extension TrackersViewController: TrackersViewControllerProtocol {

    
    func showStartingBlock() {
        VoidImage.isHidden = false
        questionLabel.isHidden = false
    }
    
    func hideStartingBlock() {
        VoidImage.isHidden = true
        questionLabel.isHidden = true
    }
}
