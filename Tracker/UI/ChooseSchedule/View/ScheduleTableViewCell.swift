import UIKit

protocol ScheduleTableViewCellDelegate: AnyObject {
    func weekDaySelected(_ weekDay: Int)
    func weekDayUnselected(_ weekDay: Int)
}

final class ScheduleTableViewCell: UITableViewCell {
    // MARK: - Public
    func configure(with indexPath: IndexPath, for set: Set<Int>) {
        // set tag same as indexPath
        weakDaySwitch.tag = indexPath.row
        // set static text
        weakDayLabel.text = WeekDay(rawValue: indexPath.row)?.abbreviationLong
        // set switch to on or off position
        weakDaySwitch.isOn = set.contains(indexPath.row)
    }
    
    // MARK: - Delegate
    weak var delegate: ScheduleTableViewCellDelegate?
    
    // MARK: - Private properties
    private let weakDayLabel: UILabel = {
        let view = UILabel()
        view.textColor = Asset.Colors.myBlack.color
        view.font = .regular17
        return view
    }()
    
    private let weakDaySwitch: UISwitch = {
        let weakDaySwitch = UISwitch()
        weakDaySwitch.onTintColor = Asset.Colors.myBlue.color
        weakDaySwitch.backgroundColor = Asset.Colors.myLightGrey.color
        weakDaySwitch.layer.cornerRadius = .cornerRadius
        weakDaySwitch.layer.masksToBounds = true
        return weakDaySwitch
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - Private @objc target action methods
    @objc private func handleWeakDaySwitch(_ sender: UISwitch) {
        if sender.isOn {
            delegate?.weekDaySelected(weakDaySwitch.tag)
        } else {
            delegate?.weekDayUnselected(weakDaySwitch.tag)
        }
    }
}

// MARK: - Private methods
private extension ScheduleTableViewCell {
    func setupUI() {
        weakDaySwitch.addTarget(self, action: #selector(handleWeakDaySwitch), for: .touchUpInside)
        stackView.addSubviews(weakDayLabel, weakDaySwitch)
        contentView.addSubviews(stackView)
        contentView.backgroundColor = Asset.Colors.myBackground.color
        
        selectionStyle = .none
        
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
