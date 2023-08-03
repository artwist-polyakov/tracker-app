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
    let emojiLabel: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 68
        return image
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
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(sheet)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
