import UIKit

final class CreateTrackerCollectionEmojiCell: UICollectionViewCell, Highilable {
    // MARK: - Public
    func configure(with emoji: String) {
        text.text = emoji
    }
    
    var content: String? {
        text.text
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
    
    // MARK: - Private properties
    private let text: UILabel = {
        let view = UILabel()
        view.font = .bold32
        view.textAlignment = .center
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
}

// MARK: Private methods
private extension CreateTrackerCollectionEmojiCell {
    func setupUI() {
        contentView.addSubviews(text)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            text.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            text.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configureCell() {
        switch cellState {
        case .selected:
            contentView.backgroundColor = Asset.Colors.myLightGrey.color
        case .unselected:
            contentView.backgroundColor = .clear
        }
    }
}
