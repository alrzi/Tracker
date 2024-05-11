import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Private properties
    private let placeholderView = PlaceholderView(state: .question)
    private let headerView = TrackerHeaderView()
    private let searchView = SearchView()
    private let filterButton: UIButton = {
        let view = UIButton()
        view.layer.cornerRadius = .cornerRadius
        view.layer.masksToBounds = true
        view.setTitle(Strings.Localizable.Filters.title, for: .normal)
        view.titleLabel?.font = .regular17
        view.backgroundColor = Asset.Colors.myBlue.color
        return view
    }()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = Asset.Colors.myWhite.color
        view.allowsSelection = true
        view.registerHeader(TrackerCollectionHeader.self)
        view.register(cellClass: TrackerCollectionViewCell.self)
        return view
    }()
    // Layout of collection helper
    private let params = GeometryParams(
        cellCount: UIConstants.cellCount,
        cellSize: .zero,
        leftInset: UIConstants.inset,
        rightInset: UIConstants.inset,
        topInset: .zero,
        bottomInset: .zero,
        spacing: UIConstants.cellSpacing
    )
    
    // MARK: - UIConstants
    private enum UIConstants {
        static let trackerHeaderHeight: CGFloat = 30
        static let inset: CGFloat = 16
        static let trailingInset: CGFloat = -16
        static let topInset: CGFloat = 13
        static let collectionToSearchViewOffset: CGFloat = 10
        static let headerHeight: CGFloat = 72
        static let searchHeight: CGFloat = 36
        static let searchLeading: CGFloat = 8
        static let searchTrailing: CGFloat = -8
        static let cellSpacing: CGFloat = 9
        static let cellHeight: CGFloat = 148
        static let cellCount = 2
    }
    
    // MARK: - Models
    private let analiticService = AnalyticsService()
    private var dataProvider: DataProviderProtocol?
    private lazy var alertPresenter = AlertPresenter(presentingViewController: self)

    private var currentFilter: FiltersViewController.Filters = .forToday
    private var currentDay = Date()
    private var currentWeekdayString: String { currentDay.weekDayString }
    private var currentDateString: String { currentDay.dateString }

    init(dataProvider: DataProviderProtocol?) {
        self.dataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)
        self.dataProvider?.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setDelegates()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        analiticService.handleAnalitics(event: .screenOpen(.main))
        if let isEmpty = dataProvider?.isEmpty, isEmpty {
            placeholderView.state = .question
            switch currentFilter {
            case .all:
                filterButton.isHidden = true
            case .forToday:
                filterButton.isHidden = true
            case .completed, .uncompleted:
                filterButton.isHidden = false
            }
        } else {
            placeholderView.state = .invisible(animate: false)
            filterButton.isHidden = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        analiticService.handleAnalitics(event: .screenClose(.main))
    }
    
    // MARK: - @objc target action methods
    func handlePlusButtonTap() {
        analiticService.handleAnalitics(event: .addTracker(.main, .addTrack))
        let trackerCreationViewController = ChooseTrackerViewController()
        present(trackerCreationViewController, animated: true)
    }
    
    @objc func hideKeyboard() {
        searchView.hideKeyboard()
    }
    
    @objc func filterTrackers() {
        analiticService.handleAnalitics(event: .filterItemClick(.main, .filter))
        let filtersVC = FiltersViewController(filter: currentFilter)
        filtersVC.filterSelected = { [weak self] filter in
            self?.currentFilter = filter
            self?.handle(filters: filter, searchText: nil)
        }
        present(filtersVC, animated: true)
    }
}

// MARK: - Private methods
private extension TrackersViewController {
    func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        filterButton.addTarget(self, action: #selector(filterTrackers), for: .touchUpInside)
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = Asset.Colors.myWhite.color
        view.addSubviews(headerView, searchView, collectionView, placeholderView, filterButton)
    }
    
    func setDelegates() {
        searchView.delegate = self
        headerView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: UIConstants.topInset),
            headerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: UIConstants.inset),
            headerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: UIConstants.trailingInset),
            headerView.heightAnchor.constraint(
                equalToConstant: UIConstants.headerHeight)
        ])
        
        NSLayoutConstraint.activate([
            searchView.topAnchor.constraint(
                equalTo: headerView.bottomAnchor,
                constant: UIConstants.topInset),
            searchView.heightAnchor.constraint(equalToConstant: UIConstants.searchHeight),
            searchView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: UIConstants.searchLeading),
            searchView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: UIConstants.searchTrailing)
        ])
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(
                equalTo: searchView.bottomAnchor,
                constant: UIConstants.collectionToSearchViewOffset),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    func handle(filters: FiltersViewController.Filters, searchText: String?) {
        do {
            switch filters {
            case .all:
                if let searchText {
                    try dataProvider?.fetchTrackersWith(name: searchText, forWeekDay: currentWeekdayString)
                } else {
                    try dataProvider?.fetchTrackersFor(weekDay: currentWeekdayString)
                }
            case .forToday:
                currentDay = Date()
                headerView.setDate(date: Date())
                if let searchText {
                    try dataProvider?.fetchTrackersWith(name: searchText, forWeekDay: Date().weekDayString)
                } else {
                    try dataProvider?.fetchTrackersFor(weekDay: currentWeekdayString)
                }
            case .completed:
                if let searchText {
                    try dataProvider?.fetchCompletedTrackersWith(
                        name: searchText, forDate: currentDateString)
                } else {
                    try dataProvider?.fetchCompletedTrackersFor(date: currentDateString)
                }
            case .uncompleted:
                if let searchText {
                    try dataProvider?.fetchUncompletedTrackersWith(name: searchText, forWeekDay: currentWeekdayString, andForDate: currentDateString)
                } else {
                    try dataProvider?.fetchUncompletedTrackersFor(weekDay: currentWeekdayString, andForDate: currentDateString)
                }
            }
            collectionView.reloadData()
        } catch {
            print(error)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        dataProvider?.numberOfSections ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataProvider?.numberOfRowsInSection(section) ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TrackerCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        let tracker = dataProvider?.getTracker(at: indexPath)
        let daysTracked = dataProvider?.daysTracked(for: indexPath)

        let isCompleted = dataProvider?.isTrackerAt(indexPath: indexPath, completedForDate: currentDateString)

        cell.configure(with: tracker)
        cell.configure(with: daysTracked, isCompleted: isCompleted)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header: TrackerCollectionHeader = collectionView.dequeueHeader(
            ofKind: UICollectionView.elementKindSectionHeader,
            for: indexPath
        )
        header.configure(with: dataProvider?.header(for: indexPath.section) ?? "")
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.emptySpaceWidth
        let width = availableWidth / CGFloat(params.cellCount)
        return CGSize(width: width, height: UIConstants.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: params.topInset, left: params.leftInset, bottom: params.bottomInset, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return UIConstants.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: UIConstants.trackerHeaderHeight)
    }
}

// MARK: - TrackerCollectionViewCellDelegate
extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func didMarkTrackerCompleted(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        do {
            analiticService.handleAnalitics(event: .trackItemClick(.main, .track))
            try dataProvider?.saveAsCompletedTracker(with: indexPath, for: currentDateString)
        } catch {
            print("⛈️", error)
        }
    }
    
    func didAttachTracker(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        dataProvider?.pinTrackerAt(indexPath: indexPath)
    }
    
    func didUnattachTracker(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        dataProvider?.unPinTrackerAt(indexPath: indexPath)
    }
    
    func didDeleteTracker(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        analiticService.handleAnalitics(event: .deleteItemClick(.main, .delete))
        alertPresenter.show(message: Strings.Localizable.Alert.confirmationTracker) { [weak self] in
            try? self?.dataProvider?.deleteTracker(at: indexPath)
        }
    }
    
    func didUpdateTracker(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell),
            let tracker = dataProvider?.getTracker(at: indexPath) else { return }
        analiticService.handleAnalitics(event: .editItemClick(.main, .edit))
        let updateTrackerViewModel = CreateTrackerViewModelImpl(
            trackerKind: tracker.kind, tracker: tracker, date: currentDateString)
        
        let updateTrackerViewController = CreateTrackerViewController(viewModel: updateTrackerViewModel)
        
        present(updateTrackerViewController, animated: true)
    }
}

// MARK: - TrackerHeaderViewDelegate
extension TrackersViewController: TrackerHeaderViewDelegate {
    func datePickerValueChanged(date: Date) {
        currentDay = date
        do {
            if currentFilter == .forToday {
                try dataProvider?.fetchTrackersFor(weekDay: currentWeekdayString)
                currentFilter = .all
                collectionView.reloadData()
            } else {
                handle(filters: currentFilter, searchText: nil)
            }
        } catch {
            print("🏹", error)
        }
    }
}

// MARK: - SearchViewDelegate
extension TrackersViewController: SearchViewDelegate {
    func searchView(_ searchView: SearchView, textDidChange searchText: String) {
        handle(filters: currentFilter, searchText: searchText)
    }
}

// MARK: - DataProviderDelegate
extension TrackersViewController: DataProviderDelegate {
    func place() {
        placeholderView.state = .question
    }
    
    func noResultFound() {
        placeholderView.state = .noResult
    }
    
    func resultFound() {
        placeholderView.state = .invisible(animate: true)
    }
    
    func didUpdate(_ update: DataProviderUpdate) {
        collectionView.performBatchUpdates {
            if !update.insertedIndexes.isEmpty {
                collectionView.insertItems(at: [update.insertedIndexes])
            }
            if !update.insertedSection.isEmpty {
                collectionView.insertSections(update.insertedSection)
            }
            if !update.deletedIndexes.isEmpty {
                collectionView.deleteItems(at: [update.deletedIndexes])
            }
            if !update.deletedSection.isEmpty {
                collectionView.deleteSections(update.deletedSection)
            }
            if !update.updatedIndexes.isEmpty {
                collectionView.reloadItems(at: [update.updatedIndexes])
            }
            if !update.movedIndexes.isEmpty {
                for move in update.movedIndexes {
                    collectionView.moveItem(
                        at: move.oldIndexPath,
                        to: move.newIndexPath
                    )
                }
            }
        } completion: { _ in
            for move in update.movedIndexes {
                if update.deletedSection.isEmpty && update.insertedSection.isEmpty {
                    self.collectionView.reloadItems(at: [move.newIndexPath])
                }
            }
        }
    }
}
