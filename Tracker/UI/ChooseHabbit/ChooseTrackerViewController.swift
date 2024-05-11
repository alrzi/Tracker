import UIKit

final class ChooseTrackerViewController: UIViewController {
    // MARK: Private properties
    private let nameOfScreenLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.Localizable.Choosing.tracker
        label.font = .medium16
        label.textAlignment = .center
        return label
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = UIConstants.stackViewSpacing
        return view
    }()
    
    let habitButton = ActionButton(
        colorType: .black,
        title: Strings.Localizable.Choosing.trackerType1)
    
    let irregularEventButton = ActionButton(
        colorType: .black,
        title: Strings.Localizable.Choosing.trackerType2)
    
    // MARK: UIConstants
    private enum UIConstants {
        static let nameLabelTopInset: CGFloat = 27
        static let stackViewSpacing: CGFloat = 16
        static let buttonsCornerRadius: CGFloat = 16
        static let stackLeadingInset: CGFloat = 20
        static let stackTrailingInset: CGFloat = -20
        static let buttonsHeight: CGFloat = 60
    }
    
    var initialInteractivePopGestureRecognizerDelegate: UIGestureRecognizerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }
    
    // MARK: - Private @objc target action methods
    @objc private func habitButtonTaped() {
        pushCreateTrackerViewController(kind: .habit)
    }
    
    @objc private func irregularEventButtonTapped() {
        pushCreateTrackerViewController(kind: .ocasional)
    }
    
    private func pushCreateTrackerViewController(kind: Tracker.Kind) {
        let viewModel = CreateTrackerViewModelImpl(trackerKind: kind, tracker: nil, date: nil)
        let vc = CreateTrackerViewController(viewModel: viewModel)
        present(vc, animated: true)
    }
}

// MARK: - Private methods
private extension ChooseTrackerViewController {
    func setupUI() {
        // Add targets
        habitButton.addTarget(
            self, action: #selector(habitButtonTaped), for: .touchUpInside)
        irregularEventButton.addTarget(
            self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        
        // Add subviews
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
