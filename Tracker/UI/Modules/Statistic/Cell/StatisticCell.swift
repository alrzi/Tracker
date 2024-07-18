import UIKit
import Combine

final class StatisticTableViewCell: UITableViewCell {
    // MARK: - Configuration
    func configure(with title: String) {
        descriptionLabel.text = title
    }

    func bind(to viewModel: StatisticCellViewModel) {
        viewModel.$value
            .sink { [weak self] value in
                self?.daysLabel.text = value
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Properties
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = .bold34
        label.textColor = Asset.Colors.myBlack.color
        label.numberOfLines = 1
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .medium12
        label.textColor = Asset.Colors.myBlack.color
        label.numberOfLines = 1
        return label
    }()

    let container = UIView()
    let gradient = CAGradientLayer()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        addConstraints()
        addGradient()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        gradient.removeFromSuperlayer()
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }

    func setupUI() {
        contentView.backgroundColor = Asset.Colors.myWhite.color
        contentView.addSubviews(container)
        container.addSubviews(daysLabel, descriptionLabel)
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 90),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            daysLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            daysLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),

            descriptionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            descriptionLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
    }

    func addGradient() {
        gradient.frame =  CGRect(origin: CGPoint.zero, size: container.frame.size)
        gradient.colors = [
            Asset.Colors.gradientRed.color.cgColor,
            Asset.Colors.gradientGreen.color.cgColor,
            Asset.Colors.gradientBlue.color.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)

        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.path = UIBezierPath(
            roundedRect: container.bounds,
            cornerRadius: container.layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape

        container.layer.addSublayer(gradient)
    }
}
