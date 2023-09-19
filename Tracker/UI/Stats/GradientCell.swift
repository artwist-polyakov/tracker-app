import Foundation
import UIKit

import UIKit

class GradientCell: UITableViewCell {
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    static let cellHeight: CGFloat = 90
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        // Добавляем подконтейнер для градиента
        let gradientContainer = UIView(frame: bounds)
        gradientContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gradientContainer)
        
        // Создаём градиент
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1).cgColor,
                                UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor,
                                UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        gradientContainer.layer.addSublayer(gradientLayer)
        
        // Ограничиваем ширину градиентного слоя
        gradientLayer.frame.size.height = 1
        gradientLayer.frame.origin.y = bounds.height - 1
        
        addSubview(valueLabel)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            gradientContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            gradientContainer.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Обновляем frame градиентного слоя, когда layoutSubviews вызывается
        if let gradientLayer = (subviews.first { $0 is UIView } as? UIView)?.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame.size.width = bounds.width
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 90)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 90)
    }
}

