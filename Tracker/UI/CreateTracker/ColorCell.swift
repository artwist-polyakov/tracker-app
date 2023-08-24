import UIKit
class ColorCell: UICollectionViewCell {
    
    var isSelectedColor: Bool = false {
        didSet {
            if isSelectedColor {
                contentView.layer.cornerRadius = 8
                contentView.layer.borderWidth = 3
                contentView.layer.borderColor = colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
            } else {
                contentView.layer.cornerRadius = 0
                contentView.layer.borderWidth = 0
            }
        }
    }
    
    var cellWidth: CGFloat = 0
    
    let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 4/5),
            colorView.heightAnchor.constraint(equalTo: colorView.widthAnchor)
        ])
        colorView.layer.cornerRadius = 6
    }
}
