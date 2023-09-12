import UIKit

final class TrackersViewController: UIViewController {
    
    var addBarButtonItem: UIBarButtonItem?
    var collectionView: UICollectionView?
    var collectionPresenter: TrackersCollectionsPresenter!
    var collectionCompanion: TrackersCollectionsCompanion?
    private var isSearchFocused: Bool  = false
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.maximumDate = Date()
        return picker
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.trackers
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    let questionLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("emptyState.title",
                                       value: "Нет значения",
                                       comment: "Сообщение при пустом экране")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    let voidImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "VoidImage")
        return image
    }()
    
    var searchField: UISearchTextField = {
        let field = UISearchTextField()
        field.text = L10n.search
        field.backgroundColor = UIColor(named: "TrackerSearchFieldColor")
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.view.addGestureRecognizer(longPressRecognizer)
        
        collectionPresenter = TrackersCollectionsPresenter(vc: self)
        collectionCompanion = TrackersCollectionsCompanion(vc: self, delegate: collectionPresenter)
        collectionPresenter.selectedDate = self.datePicker.date
        view.backgroundColor = UIColor(named: "TrackerWhite")
        searchField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.backgroundColor = UIColor(named: "TrackerWhite")
        
        collectionView?.dataSource = collectionCompanion
        collectionView?.delegate = collectionCompanion
        collectionView?.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCollectionViewCell")
        collectionView?.register(SupplementaryViewMain.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        if let collection = collectionView {
            view.addSubview(collection)
        }
        
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
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
        ])
        
        
        
        view.addSubview(voidImage)
        voidImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            voidImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            voidImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            voidImage.widthAnchor.constraint(equalToConstant: 80),
            voidImage.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        view.addSubview(questionLabel)
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: voidImage.bottomAnchor, constant: 8),
            questionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        guard let collection = collectionView else { return }
        NSLayoutConstraint.activate([
              collection.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 16),
              collection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
              collection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
              collection.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
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
        collectionPresenter.selectedDate = SimpleDate(date: sender.date).date
        collectionCompanion?.selectedDate = SimpleDate(date: sender.date).date
        collectionView?.reloadData()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        collectionCompanion?.typedText = textField.text
        isSearchFocused = true
        collectionView?.reloadData()
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            showDeleteDataAlert()
            
        }
    }
    
    
    func setupButtons() {
        addBarButtonItem = {
            let barButtonItem = UIBarButtonItem(
                image: UIImage (named: "Add" ),
                style: .plain,
                target: self,
                action: #selector (addButtonTapped)
            )
            barButtonItem.tintColor = UIColor (named: "TrackerBlack")
            return barButtonItem
        }()
    }
    
    func showFutureDateAlert() {
        let alertPresenter = AlertPresenter()
        let alert = AlertModel(title: L10n.Dont.lie, message: L10n.Dont.Lie.message, primaryButtonText: L10n.sorry, primaryButtonCompletion: {})
        alertPresenter.show(in: self, model:alert)
    }
    
    func showDeleteDataAlert() {
        let alertPresenter = AlertPresenter()
        let alert = AlertModel(
            title: L10n.Clear.data,
            message: L10n.Clear.Data.agreement,
            primaryButtonText: L10n.cancel,
            primaryButtonCompletion: {},
            secondaryButtonText: L10n.Delete.this,
            secondaryButtonCompletion: {
                self.collectionPresenter.handleClearAllData()
                self.collectionPresenter.resetState()
                self.collectionPresenter.quantityTernar(0)
            })
        alertPresenter.show(in: self, model:alert)
    }
    
    @objc func dismissKeyboard()  {
        searchField.resignFirstResponder()
        isSearchFocused = false
    }
    
}

extension TrackersViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchField.text = ""
        collectionCompanion?.typedText = ""
        collectionView?.reloadData()
        textField.textColor = UIColor(named: "TrackerBlack")
        isSearchFocused = true
    }
}


extension TrackersViewController: TrackersViewControllerProtocol {
    
    
    func showStartingBlock() {
        voidImage.isHidden = false
        questionLabel.isHidden = false
    }
    
    func hideStartingBlock() {
        voidImage.isHidden = true
        questionLabel.isHidden = true
    }
    
    func updateStartingBlockState(_ state: PRESENTER_ERRORS) {
        switch (state) {
        case .NOT_FOUND:
            voidImage.image = UIImage(named: "NotFoundImage")
            questionLabel.text = L10n.Nothing.found
        default:
            voidImage.image = UIImage(named: "VoidImage")
            questionLabel.text = L10n.EmptyState.title
        }
    }
}

extension TrackersViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if searchField.isFirstResponder {
            return true
        } else {
            if let control = touch.view as? UIControl, control.isEnabled && isSearchFocused {
                control.sendActions(for: .touchUpInside)
            }
            return false
        }
    }
}
