import Foundation
import UIKit

final class DaysCountLabel: UITableViewCell {
    
    let daysLabel = UILabel()
    static let cellHeight: CGFloat = 34
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        self.selectionStyle = .none
        self.backgroundColor = UIColor(white: 1, alpha: 0)
        
        daysLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        daysLabel.textColor = UIColor(named: "TrackerBlack")
        daysLabel.textAlignment = .center
        
        addSubview(daysLabel)
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            daysLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            daysLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            daysLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            daysLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    func configure(days: Int, isActive: Bool) {
        daysLabel.text = L10n.daysStrike(days)
        daysLabel.isHidden = !isActive
    }
}

