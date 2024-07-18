import UIKit
import Combine

final class TrackersViewController: UIViewController {
    // MARK: - Private properties
    
    private lazy var alertPresenter = AlertPresenter(presentingViewController: self)
    private lazy var placeholderView = PlaceholderView(state: .question)
    
    private lazy var headerView: TrackerHeaderView = {
        TrackerHeaderView(
            onPlusButton: viewModel.onCreateTracker,
            onDatePickerValueChanged: viewModel.onDateChanged
        )
    }()
    
    private lazy var searchView: SearchView = {
        SearchView(onTextChange: viewModel.onSearchTextChange)
    }()
    
    private lazy var filterButton: UIButton = {
        let view = UIButton()
        view.layer.cornerRadius = .cornerRadius
        view.layer.masksToBounds = true
        view.setTitle(Strings.Localizable.Filters.title, for: .normal)
        view.titleLabel?.font = .regular17
        view.backgroundColor = Asset.Colors.myBlue.color
        view.addTarget(self, action: #selector(filterTrackers), for: .touchUpInside)
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.backgroundColor = Asset.Colors.myWhite.color
        view.allowsSelection = true
        view.registerHeader(TrackerCollectionHeader.self)
        view.register(cellClass: TrackerCollectionViewCell.self)
        return view
    }()
    
    private lazy var dataSource: TrackersDataSource = {
        TrackersDataSource(collectionView: collectionView)
    }()
    
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
        
    private let viewModel: TrackersViewModel
    private var cancellables: Set<AnyCancellable> = []

    init(viewModel: TrackersViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        
        viewModel.$pinnedTrackers
            .compactMap { $0 }
            .sink { [weak self] in self?.updateSnapshot(with: $0) }
            .store(in: &cancellables)
        
        viewModel.$trackerCategories
            .sink { [weak self] in self?.updateSnapshot(with: $0) }
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.onAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.onDisappear()
    }
    
    @objc internal func hideKeyboard() {
        searchView.hideKeyboard()
    }
    
    @objc private func filterTrackers() {
        viewModel.onFilterButton()
    }
    
    private func updateSnapshot(with sections: [TrackerCategory]) {
        dataSource.reload(sections)
    }
    
    private func updateSnapshot(with sections: TrackerCategory) {
        dataSource.reload(sections)
    }
}

// MARK: - Private methods
private extension TrackersViewController {
    func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = Asset.Colors.myWhite.color
        
        view.addSubviews(
            headerView,
            searchView,
            collectionView,
            placeholderView,
            filterButton
        )
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
    
    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, _ in
            // Item
            let itemInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 8, trailing: 12)
            let item = NSCollectionLayoutItem.create(
                withWidth: .fractionalWidth(0.5),
                height: .fractionalHeight(1),
                insets: itemInsets
            )

            // Group
            let group = NSCollectionLayoutGroup.create(
                horizontalGroupWithWidth: .fractionalWidth(1.0),
                height: .absolute(150),
                items: [item]
            )
            
            // Header
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(44)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )

            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [header]
            section.contentInsets = itemInsets

            return section
        }
    }
}

// MARK: - TrackerCollectionViewCellDelegate

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func didMarkTrackerCompleted(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { 
            return
        }
        
        viewModel.onTrackerMarkCompleted(at: indexPath)
    }
    
    func didAttachTracker(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
                
        viewModel.onPinTracker(at: indexPath)
    }
    
    func didUnattachTracker(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { 
            return
        }
                
        viewModel.onPinTracker(at: indexPath)
    }
    
    func didDeleteTracker(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { 
            return
        }
                        
        alertPresenter.show(message: Strings.Localizable.Alert.confirmationTracker) { [viewModel] in
            viewModel.onDeleteTracker(at: indexPath)
        }
    }
    
    func didUpdateTracker(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        viewModel.onUpdateTracker(at: indexPath)        
    }
}
