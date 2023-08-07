//
//  ColorCell.swift
//  Tracker
//
//  Created by Александр Поляков on 07.08.2023.
//

import UIKit
class ColorCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.backgroundColor = .brown
        // Здесь можно добавить дополнительную настройку, если она будет нужна в будущем
        // На данный момент, в основном, мы будем устанавливать цвет фона, так что дополнительная настройка не требуется.
    }
}
