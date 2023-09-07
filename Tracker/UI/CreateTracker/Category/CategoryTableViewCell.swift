import Foundation
import UIKit

final class CategoryTableViewCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let separatorView = UIView()
    let checkmarkImageView = UIImageView(image: UIImage(named: "Done"))
    var targetCategory: TrackerCategory?
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
        self.selectionStyle = .none
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = UIColor(named: "TrackerBlack")
        
        let labelsContainer = UIView()
        addSubview(labelsContainer)
        labelsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        labelsContainer.addSubview(titleLabel)
        checkmarkImageView.tintColor = UIColor(named: "TrackerGray")
        self.backgroundColor = UIColor(white: 1, alpha: 0)
        
        addSubview(checkmarkImageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            checkmarkImageView.centerYAnchor.constraint(equalTo: labelsContainer.centerYAnchor),
            checkmarkImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            labelsContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelsContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
        ])
        
    }
    
}

