import UIKit

protocol Highilable {
    var content: String? { get }
    func unhighlight()
    func highlight()
    func toggle() -> Bool
}

final class CreateTrackerCollectionColorCell: UICollectionViewCell, Highilable {
    // MARK: Public
    func configure(with color: String) {
        colorView.backgroundColor = UIColor(hexString: color)
    }
    
    var content: String? {
        colorView.backgroundColor?.toHexString()
    }
    
    func toggle() -> Bool {
        cellState.toggle()
    }
    
    func unhighlight() {
        cellState = .unselected
    }
    
    func highlight() {
        cellState = .selected
    }
    
    // MARK: - Cell State
    private var cellState = State.unselected {
        didSet {
            configureCell()
        }
    }

    // MARK: Private properties
    private let text: UILabel = {
        let view = UILabel()
        view.font = .bold32
        return view
    }()
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let highlightedImage: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        highlightedImage.image = nil
    }
}

// MARK: Private methods
private extension CreateTrackerCollectionColorCell {
    func initialise() {
        contentView.addSubviews(colorView, highlightedImage)
        
        NSLayoutConstraint.activate([
            highlightedImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            highlightedImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    func configureCell() {
        switch cellState {
        case .selected:
            let image = Asset.Assets._09cellBorder.image
                .withTintColor(colorView.backgroundColor ?? .clear, renderingMode: .alwaysOriginal)
            UIView.animate(withDuration: 0.3, delay: 0) {
                self.highlightedImage.image = image
            }
        case .unselected:
            highlightedImage.image = nil
        }
    }
}
