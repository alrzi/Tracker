import Foundation
import UIKit
import TrackerDomain

final class FiltersViewController: FrameViewController {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, TrackerFilters>
    
    private lazy var dataSource = UITableViewDiffableDataSource<Int, TrackerFilters>(tableView: tableView) { [weak self] collectionView, indexPath, filter in
        let cell = collectionView.dequeueReusableCell(for: indexPath)
        cell.textLabel?.text = filter.description
        cell.backgroundColor = .systemBackground
        cell.selectionStyle = .none
        if TrackerFilters.allCases[indexPath.row] == self?.currentFilter {
            cell.accessoryType = .checkmark
        } 
        else if self?.currentFilter == nil && indexPath.row == 1 {
            cell.accessoryType = .checkmark
        } 
        else {
            cell.accessoryView = .none
        }
        return cell
    }
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.contentInset.top = UIConstants.topInset
        view.separatorInset.left = .leadingInset
        view.separatorInset.right = .leadingInset
        view.separatorColor = .gray
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.delegate = self
        view.register(cellClass: UITableViewCell.self)
        return view
    }()
    
    // MARK: UIConstants
    private enum UIConstants {
        static let topInset: CGFloat = 24
        static let bottomInset: CGFloat = -16
    }
    
    let onFilterSelected: (TrackerFilters) -> Void
    
    private var currentFilter: TrackerFilters
    
    init(
        filter: TrackerFilters,
        onFilterSelected: @escaping (TrackerFilters) -> Void
    ) {
        self.currentFilter = filter
        self.onFilterSelected = onFilterSelected
        
        super.init(title: "Strings.Localizable.Filters.title", buttonCenter: .none)
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
        snapshot.appendItems(TrackerFilters.allCases)
        dataSource.apply(snapshot)
    }
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onFilterSelected(TrackerFilters.allCases[indexPath.row])
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
