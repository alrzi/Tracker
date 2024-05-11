import Foundation
import UIKit

final class FiltersViewController: FrameViewController {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Filters>
    
    var filterSelected: ((Filters) -> Void)?
    
    private lazy var dataSource = UITableViewDiffableDataSource<Int, Filters>(
        tableView: tableView) { [weak self] collectionView, indexPath, filter in
        let cell = collectionView.dequeueReusableCell(for: indexPath)
        cell.textLabel?.text = filter.description
        cell.backgroundColor = Asset.Colors.myBackground.color
        cell.selectionStyle = .none
        if Filters.allCases[indexPath.row] == self?.currentFilter {
            cell.accessoryType = .checkmark
        } else if self?.currentFilter == nil && indexPath.row == 1 {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryView = .none
        }
        return cell
    }
    
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.contentInset.top = UIConstants.topInset
        view.separatorInset.left = .leadingInset
        view.separatorInset.right = .leadingInset
        view.separatorColor = Asset.Colors.myGray.color
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.register(cellClass: UITableViewCell.self)
        return view
    }()
    
    // MARK: UIConstants
    private enum UIConstants {
        static let topInset: CGFloat = 24
        static let bottomInset: CGFloat = -16
    }
    
    enum Filters: CaseIterable, CustomStringConvertible {
        case all, forToday, completed, uncompleted
        
        var description: String {
            switch self {
            case .all: return Strings.Localizable.Filters.all
            case .forToday: return Strings.Localizable.Filters.today
            case .completed: return Strings.Localizable.Filters.completed
            case .uncompleted: return Strings.Localizable.Filters.notCompleted
            }
        }
    }
    
    private var currentFilter: Filters?
    
    init(filter: Filters?) {
        self.currentFilter = filter
        super.init(title: Strings.Localizable.Filters.title, buttonCenter: .none)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        makeSnapshot()
    }
}

private extension FiltersViewController {
    func setupUI() {
        tableView.delegate = self
        container.addSubviews(tableView)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: container.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: UIConstants.bottomInset)
        ])
    }
    
    func makeSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.zero])
        snapshot.appendItems(Filters.allCases)
        dataSource.apply(snapshot)
    }
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        filterSelected?(Filters.allCases[indexPath.row])
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        .cellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .zero
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .zero
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
}
