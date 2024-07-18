import UIKit

protocol ChooseScheduleViewControllerDelegate: AnyObject {
    var weekDaysToShow: ((Set<Int>) -> Void)? { get }
}

final class ChooseScheduleViewController: FrameViewController {
    // MARK: - Call Back
    var weekDaysToShow: ((Set<Int>) -> Void)?
    
    // MARK: - Private properties        
    private let tableView: UITableView = {
        let view = UITableView()
        view.contentInset.top = UIConstants.topInset
        view.separatorColor = Asset.Colors.myGray.color
        view.backgroundColor = Asset.Colors.myWhite.color
        view.allowsSelection = true
        view.separatorStyle = .singleLine
        view.showsVerticalScrollIndicator = false
        view.register(cellClass: ScheduleTableViewCell.self)
        return view
    }()
    
    // MARK: UIConstants
    private enum UIConstants {
        static let topInset: CGFloat = 24
        static let bottomInsetInset: CGFloat = -16
        static let cellHeight: CGFloat = 75
    }
    
    // MARK: - DataToChangeStatesOfSwitchesAndGiveTextToLabels
    private var selectedWeekDays: Set<Int> = []
    
    init(weekDays: Set<Int>) {
        self.selectedWeekDays = weekDays
        super.init(
            title: Strings.Localizable.schedule,
            buttonCenter: ActionButton(colorType: .black, title: Strings.Localizable.Schedule.ready)
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }
    
    // MARK: - Private @objc target action methods
    override func handleButtonCenterTap() {
        weekDaysToShow?(selectedWeekDays)
        dismiss(animated: true)
    }
}

// MARK: - Private Methods
private extension ChooseScheduleViewController {
    func setupUI() {
        // Table in container:
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add all to container and constraint to it
        container.addSubviews(tableView)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: container.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: UIConstants.bottomInsetInset)
        ])
    }
}

// MARK: - UITableViewDataSource
extension ChooseScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ScheduleTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.setCorners(in: tableView, at: indexPath)
        cell.configure(with: indexPath, for: selectedWeekDays)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setSeparatorInset(in: tableView, at: indexPath)
    }
}

// MARK: - UITableViewDelegate
extension ChooseScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIConstants.cellHeight
    }
}

// MARK: - ScheduleTableViewCellDelegate
extension ChooseScheduleViewController: ScheduleTableViewCellDelegate {
    func weekDaySelected(_ weekDay: Int) {
        selectedWeekDays.insert(weekDay)
    }
    
    func weekDayUnselected(_ weekDay: Int) {
        selectedWeekDays.remove(weekDay)
    }
}
