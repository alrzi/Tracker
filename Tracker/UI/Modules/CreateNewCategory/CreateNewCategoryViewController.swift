import UIKit
import Combine

final class CreateNewCategoryViewController: FrameViewController {
    private lazy var textField: TrackerUITextField = {
        let view = TrackerUITextField(text: Strings.Localizable.NewCategory.enterName)
        view.delegate = self
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .fill
        view.axis = .vertical
        return view
    }()
    
    private lazy var warningCharactersLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = .zero
        view.font = .regular17
        view.textColor = Asset.Colors.myRed.color
        view.textAlignment = .center
        return view
    }()
    
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
    }
    
    // MARK: Lifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        bind(viewModel: viewModel)
    }
    
    func bind(viewModel: CreateNewCategoryViewModel) {
        viewModel.$categoryNameStatus            
            .map(\.preinstalled)
            .compactMap { $0 }
            .prefix(1)
            .sink { [weak self] name in self?.textField.set(text: name) }
            .store(in: &cancellables)
        
        viewModel.$categoryNameStatus
            .sink { [weak self] status in self?.handleAnimationFor(status: status) }
            .store(in: &cancellables)
        
        viewModel.$canCreate
            .filter { !$0 }
            .sink { [weak self] status in self?.shakeButton() }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // @objc
    override func handleButtonCenterTap() {
        viewModel.createButtonTapped()
    }
}

// MARK: - Private Methods
private extension CreateNewCategoryViewController {
    func setupUI() {
        container.addSubviews(mainStackView)
        mainStackView.addSubviews(textField, warningCharactersLabel)
        mainStackView.setCustomSpacing(16, after: textField)
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
    
    func handleAnimationFor(status: CreateNewCategoryViewModel.CategoryNameStatus) {
        switch status {
        case .empty:
            warningCharactersLabel.text = "Введите имя для категории"
            warningCharactersLabel.textColor = .systemYellow
            buttonCenter?.colorType = .grey
       
        case .available:
            warningCharactersLabel.text = "Подходящее имя"
            warningCharactersLabel.textColor = .systemGreen
            buttonCenter?.colorType = .black
        
        case .unavailable:
            warningCharactersLabel.text = Strings.Localizable.NewCategory.alreadyExist
            warningCharactersLabel.textColor = .systemRed
            buttonCenter?.colorType = .grey
        
        case .preInstalled:
            warningCharactersLabel.text = "Поменяйте иня"
            warningCharactersLabel.textColor = .systemBlue
            buttonCenter?.colorType = .black
        }
    }
    
    func shakeButton() {
        feedbackGenerator.impactOccurred()
        buttonCenter?.shakeSelf()
    }
}

// MARK: - TrackerUITextFieldDelegate
extension CreateNewCategoryViewController: TrackerUITextFieldDelegate {
    func isChangeText(text: String, newLength: Int) -> Bool? {
        viewModel.categoryNameDidEntered(name: text)
        return true
    }
}
