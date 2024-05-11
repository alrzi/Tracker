import UIKit

final class CategoryTableViewCell: UITableViewCell {
    // MARK: - Public
    var viewModel: CategoryViewModel? {
        didSet {
            categoryName.text = viewModel?.header
            if let isSelected = viewModel?.isLastSelectedCategory {
                let image = isSelected ? Asset.Assets._14checkmark.image : nil
                selectedCategory.image = image
            }
        }
    }
    
    var interactionDelegate: UIContextMenuInteractionDelegate? {
        didSet {
            if let interactionDelegate {
                self.addInteraction(UIContextMenuInteraction(delegate: interactionDelegate))
            }
        }
    }
    
    // MARK: - Private properties
    private let categoryName: UILabel = {
        let view = UILabel()
        view.textColor = Asset.Colors.myBlack.color
        view.font = .regular17
        return view
    }()
    
    private let selectedCategory: UIImageView = {
        let view = UIImageView()
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return view
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.distribution = .fill
        return view
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
}

// MARK: - Private methods
private extension CategoryTableViewCell {
    func setupUI() {
        stackView.addSubviews(categoryName, selectedCategory)
        contentView.addSubviews(stackView)
        contentView.backgroundColor = Asset.Colors.myBackground.color
        selectionStyle = .none
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: .leadingInset),
            stackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: .trailingInset),
            stackView.topAnchor.constraint(
                equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor)
        ])
    }
}
