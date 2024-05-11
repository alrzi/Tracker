import UIKit

protocol TrackerHeaderViewDelegate: AnyObject {
    func datePickerValueChanged(date: Date)
    func handlePlusButtonTap()
}

final class TrackerHeaderView: UIView {
    func setDate(date: Date) {
        datePicker.setDate(date, animated: true)
    }
    
    // MARK: - Delegate
    weak var delegate: TrackerHeaderViewDelegate?
    
    // MARK: - Private properties
    private let plusButton: ExtendedButton = {
        let button = ExtendedButton(type: .system)
        button.setImage(Asset.Assets._06plus.image, for: .normal)
        button.tintColor = Asset.Colors.myBlack.color
        return button
    }()
    
    private let trackerLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.Localizable.Main.trackers
        label.font = .bold34
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale.current
        datePicker.tintColor = .systemBlue
        datePicker.backgroundColor = Asset.Colors.myWhite.color
        datePicker.layer.cornerRadius = UIConstants.datePickerCornerRadius
        datePicker.layer.masksToBounds = true
        datePicker.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return datePicker
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fillProportionally
        return view
    }()
    
    // MARK: - UIConstants
    private enum UIConstants {
        static let trackerToPlusButtonOffset: CGFloat = 13
        static let trackerToDatePickerOffset: CGFloat = -12
        static let datePickerWidth: CGFloat = 100
        static let datePickerCornerRadius: CGFloat = 8
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - Private @objc target action methods
    @objc private func datePickerValueChanged() {
        delegate?.datePickerValueChanged(date: datePicker.date)
    }
    
    @objc private func handlePlusButtonTap() {
        delegate?.handlePlusButtonTap()
    }
}

// MARK: - Private methods
private extension TrackerHeaderView {
    func setupUI() {
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        plusButton.addTarget(self, action: #selector(handlePlusButtonTap), for: .touchUpInside)
        stackView.addSubviews(trackerLabel, datePicker)
        addSubviews(plusButton, stackView)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            plusButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            plusButton.topAnchor.constraint(equalTo: topAnchor)
        ])
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: UIConstants.datePickerWidth)
        ])
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(
                equalTo: plusButton.bottomAnchor, constant: UIConstants.trackerToPlusButtonOffset),
            stackView.heightAnchor.constraint(equalToConstant: 41)
        ])
    }
}
