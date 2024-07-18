import UIKit

final class TrackerCollectionHeader: UICollectionReusableView {
    // MARK: - Public
    func configure(with header: String) {
        categoryLabel.text = header
    }
    
    // MARK: - Private properties
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .bold19
        return label
    }()
    
    // MARK: - UIConstants
    private enum UIConstants {
        static let categoryLabelLeadingInset: CGFloat = 28
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
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
                equalTo: leadingAnchor, constant: UIConstants.categoryLabelLeadingInset),
            categoryLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            categoryLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
}
