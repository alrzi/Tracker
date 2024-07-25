import UIKit

final class ChooseTrackerViewController: UIViewController {
    private lazy var nameOfScreenLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.Localizable.Choosing.tracker
        label.font = .medium16
        label.textAlignment = .center
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = UIConstants.stackViewSpacing
        return view
    }()
    
    private lazy var habitButton: ActionButton = {
        let habitButton = ActionButton(
            colorType: .black,
            title: Strings.Localizable.Choosing.trackerType1
        )
        habitButton.addTarget(self, action: #selector(habitButtonTaped), for: .touchUpInside)
        return habitButton
    }()
    
    private lazy var irregularEventButton: ActionButton = {
        let irregularEventButton = ActionButton(
            colorType: .black,
            title: Strings.Localizable.Choosing.trackerType2
        )
        irregularEventButton.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        return irregularEventButton
    }()
    
    // MARK: UIConstants
    private enum UIConstants {
        static let nameLabelTopInset: CGFloat = 27
        static let stackViewSpacing: CGFloat = 16
        static let buttonsCornerRadius: CGFloat = 16
        static let stackLeadingInset: CGFloat = 20
        static let stackTrailingInset: CGFloat = -20
        static let buttonsHeight: CGFloat = 60
    }
    
    private var initialInteractivePopGestureRecognizerDelegate: UIGestureRecognizerDelegate?
    
    private let viewModel: ChooseTrackerViewModel
    
    init(viewModel: ChooseTrackerViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
    }
        
    @objc private func habitButtonTaped() {
        viewModel.onCreateTracker(of: .habit)
    }
    
    @objc private func irregularEventButtonTapped() {
        viewModel.onCreateTracker(of: .occasional)
    }
}

// MARK: - Private methods

private extension ChooseTrackerViewController {
    func setupUI() {
        stackView.addSubviews(habitButton, irregularEventButton)
        view.addSubviews(nameOfScreenLabel, stackView)
        view.backgroundColor = Asset.Colors.myWhite.color
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            nameOfScreenLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.nameLabelTopInset),
            nameOfScreenLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.stackLeadingInset),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: UIConstants.stackTrailingInset),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
