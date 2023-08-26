import Foundation
import UIKit

final class MenuTableViewCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let separatorView = UIView()
    let chevronImageView = UIImageView(image: UIImage(named: "Chevron"))
    static let cellHeight: CGFloat = 75
    private var titleCenterYConstraint: NSLayoutConstraint?
    private var titleTopConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = UIColor(named: "TrackerBlack")
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        subtitleLabel.textColor = UIColor(named: "TrackerGray")
        
        let labelsContainer = UIView()
        addSubview(labelsContainer)
        labelsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавление titleLabel и subtitleLabel в контейнер
        labelsContainer.addSubview(titleLabel)
        labelsContainer.addSubview(subtitleLabel)
        chevronImageView.tintColor = UIColor(named: "TrackerGray")
        self.backgroundColor = UIColor(white: 1, alpha: 0)
        
        addSubview(chevronImageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        separatorView.backgroundColor = UIColor(named: "TrackerGray")
        addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: labelsContainer.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: labelsContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: labelsContainer.trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: labelsContainer.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: labelsContainer.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: labelsContainer.bottomAnchor),
            
            chevronImageView.centerYAnchor.constraint(equalTo: labelsContainer.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            labelsContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelsContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
        ])
        
    }
    
}

