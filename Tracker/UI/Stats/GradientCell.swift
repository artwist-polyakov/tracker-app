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
    
    private let contentContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(contentContainer)
        
        contentContainer.addSubview(valueLabel)
        contentContainer.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentContainer.heightAnchor.constraint(equalToConstant: 90),
            
            valueLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 12),
            valueLabel.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 12),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -12),
        ])
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 89, width: contentView.frame.width, height: 1)
        gradientLayer.colors = [UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1).cgColor,
                                UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor,
                                UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        contentContainer.layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Обновляем frame градиентного слоя, когда layoutSubviews вызывается
        if let gradientLayer = contentContainer.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = CGRect(x: 0, y: contentContainer.frame.height - 1, width: contentContainer.frame.width, height: 1)
        }
    }
}
