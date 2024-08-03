import UIKit

final class WeekDaysSelectionViewController: FrameViewController {
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.contentInset.top = UIConstants.topInset
        view.separatorColor = Asset.Colors.myGray.color
        view.backgroundColor = Asset.Colors.myWhite.color
        view.allowsSelection = true
        view.separatorStyle = .singleLine
        view.showsVerticalScrollIndicator = false
        view.register(cellClass: ScheduleTableViewCell.self)
        view.delegate = self
        view.dataSource = self
        return view
    }()
        
    private enum UIConstants {
        static let topInset: CGFloat = 24
        static let bottomInsetInset: CGFloat = -16
        static let cellHeight: CGFloat = 75
    }
    
    private let weekDaysToShow: (Set<Int>) -> Void
    private var selectedWeekDays: Set<Int> = []
    
    init(
        weekDays: Set<Int>,
        weekDaysToShow: @escaping (Set<Int>) -> Void
    ) {
        self.selectedWeekDays = weekDays
        self.weekDaysToShow = weekDaysToShow
        
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
        weekDaysToShow(selectedWeekDays)
    }
}

// MARK: - Private Methods
private extension WeekDaysSelectionViewController {
    func setupUI() {
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
extension WeekDaysSelectionViewController: UITableViewDataSource {
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
extension WeekDaysSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIConstants.cellHeight
    }
}

// MARK: - ScheduleTableViewCellDelegate
extension WeekDaysSelectionViewController: ScheduleTableViewCellDelegate {
    func weekDaySelected(_ weekDay: Int) {
        selectedWeekDays.insert(weekDay)
    }
    
    func weekDayUnselected(_ weekDay: Int) {
        selectedWeekDays.remove(weekDay)
    }
}
