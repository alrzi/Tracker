import UIKit
import Combine

final class CategoriesListViewController: FrameViewController {
    // MARK: - Private properties
    private let placeholder = PlaceholderView(state: .recomendation)
    
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.contentInset.top = UIConstants.topInset
        view.separatorInset.left = 16
        view.separatorInset.right = 16
        view.separatorColor = Asset.Colors.myGray.color
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.register(cellClass: CategoryTableViewCell.self)
        return view
    }()
    
    // MARK: UIConstants
    private enum UIConstants {
        static let topInset: CGFloat = 24
        static let bottomInset: CGFloat = -16
    }
    
    // MARK: - Dependencies
    private var dataSource: UITableViewDiffableDataSource<Int, CategoryViewModel>?
    private var viewModel: CategoriesListViewModel
    private var cancellables = Set<AnyCancellable>()
    lazy var alertPresenter = AlertPresenter(presentingViewController: self)
    
    func bind() {
        viewModel.$categories
            .dropFirst()
            .sink { [weak self] categories in
                guard let self = self else { return }
                self.handleCategories(categories)
                self.setPlaceholder(for: categories)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Init
    init(viewModel: CategoriesListViewModel) {
        self.viewModel = viewModel
        super.init(
            title: Strings.Localizable.Category.category,
            buttonCenter: ActionButton(
                colorType: .black,
                title: Strings.Localizable.Category.addNew)
        )
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setDataSource()
        viewModel.getAllCategories()
    }
    
    // MARK: - Private @objc target action methods
    override internal func handleButtonCenterTap() {
        pushCreateNewCategoryVC(indexPath: nil)
    }
}

// MARK: - Private Methods
private extension CategoriesListViewController {
    func setupUI() {
        tableView.delegate = self
        container.addSubviews(tableView, placeholder)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            placeholder.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: container.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: UIConstants.bottomInset)
        ])
    }
    
    func setPlaceholder(for categories: [CategoryViewModel]) {
        if !categories.isEmpty {
            self.placeholder.state = .invisible(animate: false)
        } else {
            self.placeholder.state = .recomendation
        }
    }
    
    func setDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, categoryViewModel in
            let cell: CategoryTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.viewModel = categoryViewModel
            cell.interactionDelegate = self
            return cell
        }
    }
    
    func handleCategories(_ categories: [CategoryViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CategoryViewModel>()
        snapshot.appendSections([.zero])
        snapshot.appendItems(categories)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func pushCreateNewCategoryVC(indexPath: IndexPath?) {
        let selectedCategory: CategoryViewModel?
        if let indexPath = indexPath {
            selectedCategory = viewModel.getCategoryAt(indexPath: indexPath)
        } else {
            selectedCategory = nil
        }
        let viewModel = CreateNewCategoryViewModel(trackerCategory: selectedCategory, delegate: viewModel)
        let createNewCategoryVC = CreateNewCategoryViewController(viewModel: viewModel)
        present(createNewCategoryVC, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension CategoriesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        .cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.categorySelected(at: indexPath)
        dismiss(animated: true)
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

extension CategoriesListViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let location = interaction.view?.convert(location, to: tableView),
            let indexPath = tableView.indexPathForRow(at: location)
        else {
            return UIContextMenuConfiguration()
        }

        UIView.animate(withDuration: 0.3) {
            self.tableView.separatorColor = .clear
        }

        let updateAction = UIAction(title: Strings.Localizable.Context.update) { [weak self] _ in
            guard let self = self else { return }
            pushCreateNewCategoryVC(indexPath: indexPath)
        }
        
        let deleteAction = UIAction(title: Strings.Localizable.Context.delete, attributes: .destructive) { [weak self] _ in
            guard let self = self else { return }
            alertPresenter.show(message:  Strings.Localizable.Alert.confirmationCategory) { [weak self] in
                self?.viewModel.deleteCategoryAt(indexPath: indexPath)
            }
        }
        
        let menu = UIMenu(title: "", children: [updateAction, deleteAction])
        
        return UIContextMenuConfiguration(
            identifier: nil, previewProvider: nil) { _ in
                return menu
        }
    }

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        UIView.animate(withDuration: 0.3) {
            self.tableView.separatorColor = Asset.Colors.myGray.color
        }
    }
}
