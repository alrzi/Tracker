import UIKit

final class TrackerCollectionHeader: UICollectionReusableView {
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .bold19
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - Public
    func configure(with header: String) {
        categoryLabel.text = header
    }
}

// MARK: - Private methods
private extension TrackerCollectionHeader {
    func setupUI() {
        addSubviews(categoryLabel)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: 28
            ),
            categoryLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            categoryLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
}
