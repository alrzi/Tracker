import UIKit

final class CreateTrackerTableViewCell: UITableViewCell {
    // MARK: - Public
    func configure(with info: TableData?) {
        guard let info = info else { return }
        titleLabelName.text = info.title
        subtitleLabelName.text = info.subtitle
    }

    // MARK: - Private properties
    private let accessoryImageView: UIImageView = {
        let view = UIImageView()
        view.image = Asset.Assets._10chevron.image
            .withTintColor(Asset.Colors.myGray.color, renderingMode: .alwaysOriginal)
        return view
    }()
    
    private let titleLabelName: UILabel = {
        let view = UILabel()
        view.textColor = Asset.Colors.myBlack.color
        view.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return view
    }()
    
    private let subtitleLabelName: UILabel = {
        let view = UILabel()
        view.textColor = Asset.Colors.myGray.color
        view.font = .regular17
        return view
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.spacing = 2
        view.distribution = .fill
        return view
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
}

// MARK: - Private methods
private extension CreateTrackerTableViewCell {
    func setupUI() {
        contentView.addSubviews(stackView, accessoryImageView)
        contentView.backgroundColor = Asset.Colors.myBackground.color
        selectionStyle = .none
        stackView.addSubviews(titleLabelName, subtitleLabelName)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: .leadingInset),
            stackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 15),
            stackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -14),
            stackView.trailingAnchor.constraint(equalTo: accessoryImageView.leadingAnchor, constant: -10),

            accessoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            accessoryImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -24)
        ])
    }
}
