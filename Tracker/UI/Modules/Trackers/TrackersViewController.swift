import UIKit
import CoreData
import Combine

final class TrackersViewController: UIViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<TrackersSectionID, TrackersSectionItemID>
    typealias CellRegistration = UICollectionView.CellRegistration<TrackerCollectionViewCell, TrackersSectionItemID>
    typealias SupplementaryRegistration = UICollectionView.SupplementaryRegistration<TrackerCollectionHeader>
    
    private lazy var alertPresenter = AlertPresenter(presentingViewController: self)
    private lazy var placeholderView = PlaceholderView(state: .invisible(animate: false))
    
    private lazy var datePicker: UIDatePicker = with {
        $0.datePickerMode = .date
        $0.locale = Locale.current
        $0.tintColor = .systemBlue
        $0.backgroundColor = Asset.Colors.myWhite.color
        $0.layer.cornerRadius = 16
        $0.layer.masksToBounds = true
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.addTarget(self, action: #selector(onDateChanged), for: .valueChanged)
        $0.setDate(.now, animated: false)
    }
    
    private lazy var searchController = with(UISearchController(searchResultsController: nil)) {
        $0.searchResultsUpdater = self
    }
    
    private lazy var filterButton: UIButton = with {
        $0.layer.cornerRadius = .cornerRadius
        $0.layer.masksToBounds = true
        $0.setTitle(Strings.Localizable.Filters.title, for: .normal)
        $0.titleLabel?.font = .regular17
        $0.backgroundColor = Asset.Colors.myBlue.color
        $0.addTarget(self, action: #selector(onFilterButton), for: .touchUpInside)
    }
    
    private lazy var collectionView = with(UICollectionView(frame: .zero, collectionViewLayout: createLayout())) {
        $0.backgroundColor = Asset.Colors.myWhite.color
        $0.allowsSelection = true
    }
    
    private lazy var dataSource: DataSource = {
        let cellRegistration = CellRegistration { [viewModel] cell, indexPath, _ in
            guard let tracker = viewModel.state.item(at: indexPath) else {
                return
            }
            
            cell.delegate = self
            cell.configure(with: tracker)
        }
        
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        let headerRegistration = SupplementaryRegistration(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [viewModel] supplementaryView, _, indexPath in
            guard let title = viewModel.state.sectionTitle(at: indexPath) else {
                return
            }
            
            supplementaryView.configure(with: title)
        }
        
        dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        
        return dataSource
    }()
        
    private let viewModel: TrackersViewModel
    private var cancellables: Set<AnyCancellable> = []

    init(viewModel: TrackersViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        createNavigationItems()
        
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [dataSource] in dataSource.apply($0.snapshot) }
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.onAppear()
    }
    
    @objc 
    private func onFilterButton() {
        viewModel.onFilterButton()
    }
    
    @objc 
    private func onPlusButton() {
        viewModel.onCreateTracker()
    }
    
    @objc 
    private func onDateChanged() {
        viewModel.onDateChanged(date: datePicker.date)
    }
}

// MARK: - Private methods

private extension TrackersViewController {
    func setupUI() {
        view.backgroundColor = Asset.Colors.myWhite.color
        title = Strings.Localizable.Main.trackers
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubviews(collectionView, placeholderView, filterButton)
    }
    
    func createNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Asset.Assets._06plus.image,
            style: .plain,
            target: self,
            action: #selector(onPlusButton)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: datePicker
        )
        
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            // Collection View Constraints
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Placeholder View Constraints
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Filter Button Constraints
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

// MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            viewModel.onSearchTextChange(text: searchText)
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
    
    func didPinTracker(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
                
        viewModel.onPinTracker(at: indexPath)
    }
    
    func didUnPinTracker(for cell: TrackerCollectionViewCell) {
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
