//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Александр Поляков on 03.08.2023.
//

import Foundation
import UIKit

class TrackerCollectionViewCell: UICollectionViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "TrackerWhite")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()

    
    let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "❤️"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.backgroundColor = .clear
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
    
    let functionImage:UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Plus")?.withRenderingMode(.alwaysTemplate)
        return image
    }()
    
    let whiteCircle: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.3)
        view.layer.cornerRadius = 12 // половина размера 24
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        emojiLabel.insertSubview(whiteCircle, at: 0)
        whiteCircle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            whiteCircle.centerXAnchor.constraint(equalTo: emojiLabel.centerXAnchor),
            whiteCircle.centerYAnchor.constraint(equalTo: emojiLabel.centerYAnchor),
            whiteCircle.widthAnchor.constraint(equalToConstant: 24),
            whiteCircle.heightAnchor.constraint(equalToConstant: 24),
        ])
        contentView.addSubview(sheet)
        contentView.addSubview(titleLabel)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(functionImage)
        contentView.addSubview(emojiLabel)
        
        for subview in contentView.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            sheet.heightAnchor.constraint(equalToConstant: 90),
            sheet.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: sheet.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 12),
            quantityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            quantityLabel.topAnchor.constraint(equalTo: sheet.bottomAnchor, constant: 16),
            functionImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            functionImage.centerYAnchor.constraint(equalTo: quantityLabel.centerYAnchor)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String,
                   emoji: String,
                   sheetColor: UIColor,
                   quantityText: String) {
        
        titleLabel.text = text
        emojiLabel.text = emoji
        sheet.tintColor = sheetColor
        sheet.backgroundColor = sheetColor
        quantityLabel.text = quantityText
        functionImage.tintColor = sheetColor

    }
    
}
