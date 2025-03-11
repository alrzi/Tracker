import UIKit
import Combine

final class TrackerCreationViewController: UIViewController {
    private lazy var daysUpdatingView: DaysUpdaitingView = {
        let view = DaysUpdaitingView(
            incrementClosure: { [viewModel] in viewModel.incrementButtonTapped() },
            decrementClosure: { [viewModel] in viewModel.decrementButtonTapped() }
        )
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .fill
        view.axis = .vertical
        return view
    }()
    
    private lazy var titleTextfield: TrackerUITextField = {
        let view = TrackerUITextField(
            text: "Strings.Localizable.Create.enterName"
        )
        view.delegate = self
        return view
    }()
    
    private lazy var warningCharactersLabel: UILabel = {
        let view = UILabel()
        view.text = "Strings.Localizable.Create.restriction"
        view.font = .regular17
        view.textColor = .red
        view.textAlignment = .center
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.separatorColor = .gray
        view.backgroundColor = .white
        view.layer.cornerRadius = .cornerRadius
        view.register(cellClass: CreateTrackerTableViewCell.self)
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.isScrollEnabled = false
        view.allowsMultipleSelection = false
        view.isMultipleTouchEnabled = false
        view.showsVerticalScrollIndicator = false
        view.registerHeader(CreateTrackerCollectionReusableView.self)
        view.register(cellClass: CreateTrackerCollectionEmojiCell.self)
        view.register(cellClass: CreateTrackerCollectionColorCell.self)
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private let params = GeometryParams(
        cellCount: 6,
        cellSize: CGSize(width: 40, height: 40),
        leftInset: 16,
        rightInset: 16,
        topInset: 24,
        bottomInset: 24,
        spacing: 0
    )
    
    private lazy var cancelButton: ActionButton = {
        let view = ActionButton(
            colorType: .red,
            title: "Strings.Localizable.Create.cancel"
        )
        view.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var createButton: ActionButton = {
        let view = ActionButton(
            colorType: .grey,
            title: "Strings.Localizable.Create.createNew"
        )
        view.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return view
    }()

    private let buttonStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .fill
        view.distribution = .fillEqually
        return view
    }()
    
    private let container = UIView()
    private let mainScrollView = UIScrollView()
            
    // MARK: - Dependencies
    
    private let viewModel: TrackerCreationViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(viewModel: TrackerCreationViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // IndexPath representing selected item
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?
    
    // Animatable
    private var parametersCollectionViewHeight: NSLayoutConstraint?
    private var warningLabelHeight: NSLayoutConstraint?
    
    // FeedbackGenerator
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupUI()
        setupLayout()
        mainScrollView.contentInset.top = 12
        
        bind(viewModel: viewModel)
        viewModel.updateUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if parametersCollectionViewHeight?.constant != collectionView.contentSize.height {
            parametersCollectionViewHeight?.constant = collectionView.contentSize.height
        }
    }
    
    private func bind(viewModel: TrackerCreationViewModel) {
        viewModel.$tracker
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.createButton.buttonState = $0 != nil  ? .enabled : .disabled
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$updateTrackerViewModel
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updateViewModel in
                self?.updateCollectionView(with: updateViewModel)
                self?.titleTextfield.set(text: updateViewModel?.name)
            }
            .store(in: &cancellables)
        
        viewModel.$updateTrackedDaysViewModel
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updateTrackedDaysViewModel in
                guard let updateTrackedDaysViewModel else { return }
                self?.updateTracked(days: updateTrackedDaysViewModel)
            }
            .store(in: &cancellables)

        viewModel.$warningType
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] warningType in
                self?.handleWarningType(warningType)
            }
            .store(in: &cancellables)
        
        viewModel.$schedule
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &cancellables)
        
        viewModel.$categoryHeader
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &cancellables)
    }
        
    @objc private func cancelButtonTapped() {
        viewModel.onCancel()
    }

    @objc private func createButtonTapped() {
        Task {
            await viewModel.createOrUpdateTracker()
        }
        
//        feedbackGenerator.impactOccurred()
//        createButton.shakeSelf()
    }
}

// MARK: - Private methods

private extension TrackerCreationViewController {
    func setupUI() {
        mainScrollView.showsVerticalScrollIndicator = false
        
        title = "Strings.Localizable.Create.newHabit"
    }
    
    func setupLayout() {
        view.addSubviews(container, buttonStackView)
        view.backgroundColor = .white
        
        buttonStackView.addSubviews(cancelButton, createButton)
        container.addSubviews(mainScrollView)
        mainScrollView.addSubviews(mainStackView)
        
//        if viewModel.tracker != nil {
//            mainStackView.insertArrangedSubview(daysUpdatingView, at: .zero)
//            mainStackView.setCustomSpacing(40, after: daysUpdatingView)
//        }
        
        mainStackView.addSubviews(titleTextfield, warningCharactersLabel, tableView, collectionView)
        mainStackView.setCustomSpacing(8, after: titleTextfield)
        mainStackView.setCustomSpacing(16, after: warningCharactersLabel)
        mainStackView.setCustomSpacing(32, after: tableView)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            container.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),
            
            mainScrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            mainScrollView.topAnchor.constraint(equalTo: container.topAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                        
            mainStackView.leadingAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.trailingAnchor),
            mainStackView.topAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.bottomAnchor),
            
            mainStackView.widthAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.widthAnchor),
            
            titleTextfield.heightAnchor.constraint(equalToConstant: .cellHeight),
            
            tableView.heightAnchor.constraint(
                equalToConstant: CGFloat(tableView.numberOfRows(inSection: .zero) * 75)
            ),
            
            cancelButton.heightAnchor.constraint(equalToConstant: .buttonsHeight),
            
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .leadingInset),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: .trailingInset),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
        
        parametersCollectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: .zero)
        parametersCollectionViewHeight?.isActive = true
        
        warningLabelHeight = warningCharactersLabel.heightAnchor.constraint(equalToConstant: .zero)
        warningLabelHeight?.isActive = true
    }
    
    func setCreateButton(enabled: Bool) {
        createButton.buttonState = enabled ? .enabled : .disabled
    }
    
    func updateCollectionView(with viewModel: UpdateTrackerViewModel?) {
        guard let viewModel else {
            return
        }
        
        selectedEmojiIndexPath = viewModel.emoji
        selectedColorIndexPath = viewModel.color
        collectionView.reloadItems(at: [viewModel.emoji])
        collectionView.reloadItems(at: [viewModel.color])
    }
    
    func updateTracked(days: UpdateTrackedDaysViewModel) {
        daysUpdatingView.configure(with: days)
    }

    func handleWarningType(_ warningType: TrackerCreationViewModel.WarningType) {
        switch warningType {
        case .animateToShow:
            let height: CGFloat = 20
            if warningLabelHeight?.constant ==  height {
                warningCharactersLabel.shakeSelf()
            }
            animateHeight(height)
        
        case .animateToHide:
            animateHeight(.zero)
        }
    }

    func animateHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            if self.warningLabelHeight?.constant != height {
                self.warningLabelHeight?.constant = height
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension TrackerCreationViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfTableViewRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CreateTrackerTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(with: viewModel.dataForTablView[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TrackerCreationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == .zero {
            viewModel.onCategoryFlow()
        } 
        else {
            viewModel.onSchedule()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return .cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setSeparatorInset(in: tableView, at: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.emptySpaceWidth
        let size = availableWidth / CGFloat(params.cellCount)
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return params.spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: params.topInset, left: params.leftInset, bottom: params.bottomInset, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 34)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerCreationViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfCollectionSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel.getSection(indexPath) {
        case .emojiSection(let items):
            let cell: CreateTrackerCollectionEmojiCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(with: items[indexPath.row])
            if indexPath == selectedEmojiIndexPath {
                cell.highlight()
            }
            return cell
            
        case .colorSection(let items):
            let cell: CreateTrackerCollectionColorCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(with: items[indexPath.row].rawValue)
            if indexPath == selectedColorIndexPath {
                cell.highlight()
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header: CreateTrackerCollectionReusableView = collectionView.dequeueHeader(ofKind: kind, for: indexPath)
            header.configure(with: viewModel.getSection(indexPath).title)
            return header
            
        default:
            fatalError("Unexpected element kind")
        }
    }
}

// MARK: - UICollectionViewDelegate

extension TrackerCreationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch viewModel.getSection(indexPath) {
        case .emojiSection:
            collectionView.deselectOldSelectNewCellOf(
                type: CreateTrackerCollectionEmojiCell.self,
                selectedEmojiIndexPath
            ) { [weak self] emoji in
                self?.viewModel.setValue(.emoji(emoji))
                self?.selectedEmojiIndexPath = indexPath
            }
            
        case .colorSection:
            collectionView.deselectOldSelectNewCellOf(
                type: CreateTrackerCollectionColorCell.self, 
                selectedColorIndexPath
            ) { [weak self]  color in
                self?.viewModel.setValue(.color(color))
                self?.selectedColorIndexPath = indexPath
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension TrackerCreationViewController: TrackerUITextFieldDelegate {
    func isChangeText(text: String, newLength: Int) -> Bool? {
        viewModel.handleNameLogic(name: text, newNameLength: newLength)
        return !viewModel.isTextTooLong(newLength)
    }
}
