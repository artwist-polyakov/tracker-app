//
//  MenuTableViewCell.swift
//  Tracker
//
//  Created by Александр Поляков on 07.08.2023.
//

import Foundation
import UIKit

class SheduleTableViewCell: UITableViewCell {
    var targetDay: String?
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let separatorView = UIView()
    let switchControl: UISwitch = {
        let switcher = UISwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.onTintColor = UIColor(named: "TrackerBlue")
        return switcher
    }()
    
    var completionTurnOff: ((String) -> Void)?
    var completionTurnOn: ((String) -> Void)?
    
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
        
        self.backgroundColor = UIColor(white: 1, alpha: 0)
        
        addSubview(switchControl)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            switchControl.centerYAnchor.constraint(equalTo: labelsContainer.centerYAnchor),
            switchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            labelsContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelsContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
        ])
        
        addSubview(switchControl)
        NSLayoutConstraint.activate([
            switchControl.centerYAnchor.constraint(equalTo: labelsContainer.centerYAnchor),
            switchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)])
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        switchControl.isUserInteractionEnabled = true
        
        titleLabel.isUserInteractionEnabled = false
        subtitleLabel.isUserInteractionEnabled = false
        separatorView.isUserInteractionEnabled = false
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            guard let targetDay = targetDay else { return }
            completionTurnOn?(targetDay)
        } else {
            guard let targetDay = targetDay else { return }
            completionTurnOff?(targetDay)
        }
    }
    
}

