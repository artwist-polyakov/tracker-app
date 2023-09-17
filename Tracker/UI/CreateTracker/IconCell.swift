import UIKit

final class IconCell: UICollectionViewCell {
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 42, weight: .regular)
        return lbl
    }()
    
    var cellWidth: CGFloat = 0 {
        didSet {
            let fontSize = cellWidth * (4/5)
//            let fontSize = CGFloat(32)
            label.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(label)
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 16
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
        ])
    }
    
    override var isSelected: Bool {
        didSet {
            print("ОШИБКА я ячейка у меня isSelected = \(isSelected)")
            self.contentView.backgroundColor = isSelected ? UIColor(named: "TrackerLightgray") : .clear
        }
    }
    
    
}
