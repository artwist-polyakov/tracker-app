import UIKit

class IconCell: UICollectionViewCell {
    
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
            
            //            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            //            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            //            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            //            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override var isSelected: Bool {
        didSet {
            self.contentView.backgroundColor = isSelected ? UIColor(named: "TrackerGray") : .clear
        }
    }
    
    
}
