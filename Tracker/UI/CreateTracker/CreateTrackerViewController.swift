import UIKit
import Combine

final class CreateTrackerViewController: UIViewController {
    // MARK: - Private properties
    private let nameOfScreenLabel: UILabel = {
        let view = UILabel()
        view.text = Strings.Localizable.Create.newHabit
        view.font = .medium16
        view.textAlignment = .center
        return view
    }()
    
    private let daysUpdatingView = DaysUpdaitingView()

    private let mainStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .fill
        view.axis = .vertical
        return view
    }()
    
    private let titleTextfield = TrackerUITextField(
        text: Strings.Localizable.Create.enterName)
    private let warningCharactersLabel: UILabel = {
        let view = UILabel()
        view.text = Strings.Localizable.Create.restriction
        view.font = .regular17
        view.textColor = Asset.Colors.myRed.color
        view.textAlignment = .center
        return view
    }()
    
    private let tableView: UITableView = {
        let view = UITableView()
        view.separatorColor = Asset.Colors.myGray.color
        view.backgroundColor = Asset.Colors.myWhite.color
        view.layer.cornerRadius = .cornerRadius
        view.register(cellClass: CreateTrackerTableViewCell.self)
        return view
    }()

    private let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.isScrollEnabled = false
        view.allowsMultipleSelection = false
        view.isMultipleTouchEnabled = false
        view.showsVerticalScrollIndicator = false
        view.registerHeader(CreateTrackerCollectionReusableView.self)
        view.register(cellClass: CreateTrackerCollectionEmojiCell.self)
        view.register(cellClass: CreateTrackerCollectionColorCell.self)
        return view
    }()
    
    // Collection view setup
    let params = GeometryParams(
        cellCount: 6,
        cellSize: CGSize(width: 40, height: 40),
        leftInset: 16,
        rightInset: 16,
        topInset: 24,
        bottomInset: 24,
        spacing: 0
    )
    
    private let cancelButton = ActionButton(
        colorType: .red,
        title: Strings.Localizable.Create.cancel)
    // Button that is changing depending on how the data is filled
    private let createButton = ActionButton(
        colorType: .grey,
        title: Strings.Localizable.Create.createNew)

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
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: CreateTrackerViewModelImpl?
    
    // MARK: - Init
    init(viewModel: CreateTrackerViewModelImpl? = nil) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind() {
        guard let viewModel = viewModel else { return }
               
        viewModel.shouldUpdateButtonStylePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] isEnoughForTracker in
                if isEnoughForTracker {
                    self?.createButton.buttonState = .enabled
                } else {
                    self?.createButton.buttonState = .disabled
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isTrackersAddedToCoreData
            .sink { [weak self] isAdded in
                if isAdded {
                    self?.dismissScreen()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$updateTrackerViewModel
            .dropFirst()
            .sink { [weak self] updateViewModel in
                self?.updateCollectionView(with: updateViewModel)
                self?.titleTextfield.set(text: updateViewModel?.name)
            }
            .store(in: &cancellables)
        
        viewModel.$updateTrackedDaysViewModel
            .dropFirst()
            .sink { [weak self] updateTrackedDaysViewModel in
                guard let updateTrackedDaysViewModel else { return }
                self?.updateTracked(days: updateTrackedDaysViewModel)
            }
            .store(in: &cancellables)

        viewModel.$warningType
            .dropFirst()
            .sink { [weak self] warningType in
                self?.handleWarningType(warningType)
            }
            .store(in: &cancellables)
    }

    // IndexPath representing selected item
    var selectedEmojiIndexPath: IndexPath?
    var selectedColorIndexPath: IndexPath?
    // Animatable
    private var parametersCollectionViewHeight: NSLayoutConstraint?
    private var warningLabelHeight: NSLayoutConstraint?
    // FeedbackGenerator
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        addTargets()
        setupUI()
        setupLayout()
        viewModel?.updateUI()
        handleDaysUpdatingViewActions()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if parametersCollectionViewHeight?.constant != collectionView.contentSize.height {
            parametersCollectionViewHeight?.constant = collectionView.contentSize.height
        }
    }
    
    // MARK: - Private @objc target action methods
    @objc private func cancelButtonTapped() {
        dismissScreen()
    }

    @objc private func createButtonTapped() {
        if let isShaking = viewModel?.isShakingButton, isShaking {
            viewModel?.createOrUpdateTracker()
        } else {
            feedbackGenerator.impactOccurred()
            createButton.shakeSelf()
        }
    }
    
    func handleDaysUpdatingViewActions() {
        daysUpdatingView.incrementClosure = { [weak self] in
            self?.viewModel?.incrementButtonTapped()
        }
        
        daysUpdatingView.decrementClosure = { [weak self] in
            self?.viewModel?.decrementButtonTapped()
        }
    }
}

// MARK: - Private methods
private extension CreateTrackerViewController {
    func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
        titleTextfield.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func addTargets() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    func setupUI() {
        mainScrollView.showsVerticalScrollIndicator = false
    }

    func dismissScreen() {
        guard let presentingVC = presentingViewController else { return }
        dismiss(animated: false) {
            presentingVC.dismiss(animated: true, completion: nil)
        }
    }
    
    func setupLayout() {
        view.addSubviews(nameOfScreenLabel, container, buttonStackView)
        view.backgroundColor = Asset.Colors.myWhite.color
        
        buttonStackView.addSubviews(cancelButton, createButton)
        container.addSubviews(mainScrollView)
        mainScrollView.addSubviews(mainStackView)
        if viewModel?.tracker != nil {
            mainStackView.insertArrangedSubview(daysUpdatingView, at: .zero)
            mainStackView.setCustomSpacing(40, after: daysUpdatingView)
        }
        mainStackView.addSubviews(titleTextfield, warningCharactersLabel, tableView, collectionView
        )
        mainStackView.setCustomSpacing(8, after: titleTextfield)
        mainStackView.setCustomSpacing(16, after: warningCharactersLabel)
        mainStackView.setCustomSpacing(32, after: tableView)

        NSLayoutConstraint.activate([
            nameOfScreenLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            nameOfScreenLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            container.topAnchor.constraint(equalTo: nameOfScreenLabel.bottomAnchor, constant: 38),
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
        if enabled {
            createButton.buttonState = .enabled
        } else {
            createButton.buttonState = .disabled
        }
    }
    
    func updateCollectionView(with viewModel: UpdateTrackerViewModel?) {
        guard let viewModel = viewModel else { return }
        selectedEmojiIndexPath = viewModel.emoji
        selectedColorIndexPath = viewModel.color
        collectionView.reloadItems(at: [viewModel.emoji])
        collectionView.reloadItems(at: [viewModel.color])
    }
    
    func updateTracked(days: UpdateTrackedDaysViewModel) {
        daysUpdatingView.configure(with: days)
    }

    func handleWarningType(_ warningType: CreateTrackerViewModelImpl.WarningType) {
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
extension CreateTrackerViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.numberOfTableViewRows ?? .zero
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CreateTrackerTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(with: viewModel?.dataForTablView[indexPath.row])
        return cell
    }
}
// MARK: - UITableViewDelegate
extension CreateTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == .zero {
            pushCategoryListViewController()
        } else {
            let selectedWeekDays = viewModel?.schedule ?? []
            pushScheduleListViewController(weekDays: selectedWeekDays)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return .cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setSeparatorInset(in: tableView, at: indexPath)
    }
    
    // Private
    private func pushScheduleListViewController(weekDays: Set<Int>) {
        let scheduleController = ChooseScheduleViewController(weekDays: weekDays)
        present(scheduleController, animated: true)

        // Call back
        scheduleController.weekDaysToShow = { [weak self] schedule in
            guard let self = self else { return }
            self.viewModel?.setSchedule(schedule: schedule)
            self.tableView.reloadData()
        }
    }
    
    private func pushCategoryListViewController() {
        let viewModel = CategoriesListViewModel()
        let categoryController = CategoriesListViewController(viewModel: viewModel)
        present(categoryController, animated: true)
        
        // Call back
        viewModel.categoryHeader = { [weak self] header in
            guard let self = self else { return }
            self.viewModel?.addCategory(header: header)
            self.tableView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
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
        return UIEdgeInsets(
            top: params.topInset, left: params.leftInset, bottom: params.bottomInset, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 34)
    }
}
// MARK: - UICollectionViewDataSource
extension CreateTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.numberOfCollectionSections ?? .zero
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.numberOfItemsInSection(section) ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = viewModel?.getSection(indexPath) else {
            return UICollectionViewCell()
        }
        switch sectionType {
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
            header.configure(with: viewModel?.getSection(indexPath).title ?? "")
            return header
        default:
            fatalError("Unexpected element kind")
        }
    }
}
// MARK: - UICollectionViewDelegate
extension CreateTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionType = viewModel?.getSection(indexPath) else { return }
        switch sectionType {
        case .emojiSection:
            collectionView.deselectOldSelectNewCellOf(
                type: CreateTrackerCollectionEmojiCell.self, selectedEmojiIndexPath) { [weak self]  emoji in
                    self?.viewModel?.emoji = emoji
                    self?.selectedEmojiIndexPath = indexPath
            }
        case .colorSection:
            collectionView.deselectOldSelectNewCellOf(
                type: CreateTrackerCollectionColorCell.self, selectedColorIndexPath) { [weak self]  color in
                    self?.viewModel?.color = color
                    self?.selectedColorIndexPath = indexPath
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension CreateTrackerViewController: TrackerUITextFieldDelegate {
    func isChangeText(text: String, newLength: Int) -> Bool? {
        guard let viewModel = viewModel else { return true }
        viewModel.handleNameLogic(name: text, newNameLength: newLength)
        return !viewModel.isTextTooLong(newLength)
    }
}
