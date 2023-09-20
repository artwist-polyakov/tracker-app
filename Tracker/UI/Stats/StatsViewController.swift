import UIKit

final class StatsViewController: UIViewController {
    
    private var table: UITableView = UITableView()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.stats
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    let nothingLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Stats.nothingShow
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    let nothingImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "NothingImage")
        return image
    }()
    
    private var storage = StatisticResultsStorage.shared
    
    init() { // Объявление инициализатора.
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        storage.refresh() { [weak self] in
            print("обновил storage в методе viewWillAppear")
            DispatchQueue.main.async {
                self?.table.reloadData()
            }
        }
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        table.reloadData()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storage.refresh() { [weak self] in
            DispatchQueue.main.async {
                self?.table.reloadData()
            }
        }
        view.backgroundColor = UIColor(named: "TrackerWhite")
        self.navigationItem.hidesBackButton = true
        self.navigationItem.hidesSearchBarWhenScrolling = false
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        view.addSubview(nothingImage)
        nothingImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nothingImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            nothingImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nothingImage.widthAnchor.constraint(equalToConstant: 80),
            nothingImage.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        view.addSubview(nothingLabel)
        nothingLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nothingLabel.topAnchor.constraint(equalTo: nothingImage.bottomAnchor, constant: 8),
            nothingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        table.dataSource = self
        table.delegate = self
        table.register(GradientCell.self, forCellReuseIdentifier: "GradientCell")
        table.isScrollEnabled = true
        view.addSubview(table)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
        guard let data = storage.statisticResults else {
            table.isHidden = true ; return }
        print(data)
        if data.count > 0 {
            table.isHidden = false
            nothingImage.isHidden = true
            nothingLabel.isHidden = true
        } else {
            table.isHidden = true
            nothingImage.isHidden = false
            nothingLabel.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let data = storage.statisticResults else {
            table.isHidden = true ; return }
        print(data)
        if data.count > 0 {
            table.isHidden = false
            nothingImage.isHidden = true
            nothingLabel.isHidden = true
        } else {
            table.isHidden = true
            nothingImage.isHidden = false
            nothingLabel.isHidden = false
        }

        
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
}

extension StatsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = storage.statisticResults else { return 0 }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "GradientCell", for: indexPath) as! GradientCell
        cell.valueLabel.text =  storage.statisticResults?[indexPath.row].result
        cell.titleLabel.text = storage.statisticResults?[indexPath.row].title
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutIfNeeded()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
    
    
}

