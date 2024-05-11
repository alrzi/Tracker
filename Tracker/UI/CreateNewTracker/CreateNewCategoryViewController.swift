import UIKit
import Combine

final class CreateNewCategoryViewController: FrameViewController {
    // MARK: - Private properties
    private let textField = TrackerUITextField(
        text: Strings.Localizable.NewCategory.enterName)
    
    private var mainStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .fill
        view.axis = .vertical
        return view
    }()
    
    private var warningCharactersLabel: UILabel = {
        let view = UILabel()
        view.text = Strings.Localizable.NewCategory.alreadyExist
        view.numberOfLines = .zero
        view.font = .regular17
        view.textColor = Asset.Colors.myRed.color
        view.alpha = .zero
        view.textAlignment = .center
        return view
    }()
    
    // MARK: Lifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }

    // FeedbackGenerator
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let viewModel: CreateNewCategoryViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(viewModel: CreateNewCategoryViewModel) {
        self.viewModel = viewModel
        super.init(
            title: Strings.Localizable.NewCategory.new,
            buttonCenter: ActionButton(
                colorType: .grey,
                title: Strings.Localizable.NewCategory.ready)
        )
        bind()
    }
    
    func bind() {
        viewModel.$trackerCategory.sink { [weak self] category in
            self?.textField.set(text: category?.header)
        }
        .store(in: &cancellables)
        
        viewModel.$categoryNameStatus.sink { [weak self] status in
            self?.handleAnimationFor(status: status)
        }
        .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // @objc
    override func handleButtonCenterTap() {
        if !viewModel.canCreateCategory {
            feedbackGenerator.impactOccurred()
            buttonCenter?.shakeSelf()
        } else {
            viewModel.createButtonTapped()
            dismiss(animated: true)
        }
    }
}

// MARK: - Private Methods
private extension CreateNewCategoryViewController {
    func setupUI() {
        container.addSubviews(mainStackView)
        mainStackView.addSubviews(textField)
        mainStackView.setCustomSpacing(8, after: textField)
        textField.delegate = self
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            mainStackView.topAnchor.constraint(equalTo: container.topAnchor, constant: .topInsetFromTitle)
        ])
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textField.topAnchor.constraint(equalTo: container.topAnchor, constant: .topInsetFromTitle)
        ])
    }
    
    func addWarningLabel() {
        mainStackView.addArrangedSubview(warningCharactersLabel)
        UIView.animate(withDuration: 0.3) {
            self.warningCharactersLabel.alpha = 1
        }
    }
    
    func removeWarningLabel() {
        mainStackView.removeArrangedSubview(warningCharactersLabel)
        warningCharactersLabel.removeFromSuperview()
        UIView.animate(withDuration: 0.3) {
            self.warningCharactersLabel.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func handleAnimationFor(status: CreateNewCategoryViewModel.CategoryNameStatus) {
        switch status {
        case .empty:
            buttonCenter?.colorType = .grey
            removeWarningLabel()
        case .available:
            buttonCenter?.colorType = .black
            removeWarningLabel()
        case .unavailable:
            buttonCenter?.colorType = .grey
            addWarningLabel()
        }
    }
}

// MARK: - TrackerUITextFieldDelegate
extension CreateNewCategoryViewController: TrackerUITextFieldDelegate {
    func isChangeText(text: String, newLength: Int) -> Bool? {
        viewModel.categoryNameDidEnted(name: text)
        return true
    }
}
