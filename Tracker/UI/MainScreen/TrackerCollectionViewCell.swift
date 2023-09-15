import Foundation
import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    var onFunctionButtonTapped: (() -> Void)?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "TrackerWhite")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0 // Разрешить несколько строк
        label.lineBreakMode = .byWordWrapping // Перенос по словам
        return label
    }()
    
    let emojiText: UITextField = {
        let label = UITextField()
        label.backgroundColor = UIColor(white: 1, alpha: 0)
        label.textAlignment = .center
        label.layer.cornerRadius = 16
        label.text = ""
        label.tintColor = UIColor.black
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(white: 1, alpha: 0.3)
        backgroundView.layer.cornerRadius = 12
        label.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: label.centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: 24),
            backgroundView.heightAnchor.constraint(equalToConstant: 24)
        ])
        return label
    }()
    
    let sheet: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        return view
    }()
    let quantityLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "TrackerBlack")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    let functionButton: UIButton = {
        let button = UIButton(type: .system) // Используем .system для автоматического управления выделением и нажатием.
        button.setImage(UIImage(named: "Plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        return button
    }()
    
    
    let whiteCircle: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.3)
        view.layer.cornerRadius = 12 // половина размера 24
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(sheet)
        contentView.addSubview(titleLabel)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(functionButton)
        contentView.addSubview(emojiText)
        functionButton.addTarget(self, action: #selector(functionButtonTapped), for: .touchUpInside)
        
        for subview in contentView.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            sheet.heightAnchor.constraint(equalToConstant: 90),
            sheet.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: sheet.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: 12),
            emojiText.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 12),
            emojiText.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 12),
            quantityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            quantityLabel.topAnchor.constraint(equalTo: sheet.bottomAnchor, constant: 16),
            functionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            functionButton.centerYAnchor.constraint(equalTo: quantityLabel.centerYAnchor)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String,
                   emoji: String,
                   sheetColor: UIColor,
                   quantityText: String,
                   hasMark: Bool
    ) {
        
        titleLabel.text = text
        emojiText.text = emoji
        sheet.tintColor = sheetColor
        sheet.backgroundColor = sheetColor
        quantityLabel.text = quantityText
        functionButton.tintColor = sheetColor
        
        if hasMark {
            functionButton.setImage(UIImage(named: "Tick")?.withRenderingMode(.alwaysTemplate), for: .normal)
            
            
        } else {
            functionButton.setImage(UIImage(named: "Plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        
    }
    
    @objc
    func functionButtonTapped() {
        onFunctionButtonTapped?()
    }
    
}
