import UIKit

protocol FrameViewControllerProtocol {
    var container: UIView { get }
    var buttonLeft: ActionButton? { get }
    var buttonRight: ActionButton? { get }
    var buttonCenter: ActionButton? { get }
    
    func handleButtonLeftTap()
    func handleButtonRightTap()
    func handleButtonCenterTap()
}

class FrameViewController: UIViewController, FrameViewControllerProtocol {
    // MARK: - Public
    // Container to show data you want in between
    // only container and buttons are Public
    let container = UIView()
    
    // type of button
    let buttonLeft: ActionButton?
    let buttonRight: ActionButton?
    let buttonCenter: ActionButton?
    
    // MARK: - Private
    // Title of screen
    private let screenTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .medium16
        return label
    }()
    
    /// Buttons at the bottom
    private let screenButtons: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Init
    init(title: String, buttonLeft: ActionButton?, buttonRight: ActionButton?) {
        self.screenTitle.text = title
        self.buttonLeft = buttonLeft
        self.buttonRight = buttonRight
        self.buttonCenter = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    init(title: String, buttonCenter: ActionButton?) {
        self.screenTitle.text = title
        self.buttonLeft = nil
        self.buttonRight = nil
        self.buttonCenter = buttonCenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - UIConstants
    private enum UIConstants {
        static let leading: CGFloat = 16
        static let trailing: CGFloat = -16
        static let bottom: CGFloat = -24
        static let nameLabelTopInset: CGFloat = 27
        static let containerToTitleInset: CGFloat = 14
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
    }
        
    @objc 
    func handleButtonLeftTap() {}
    
    @objc
    func handleButtonRightTap() {}
    
    @objc
    func handleButtonCenterTap() {}
}
    
private extension FrameViewController {
    func setupViews() {
        buttonLeft?.addTarget(self, action: #selector(handleButtonCenterTap), for: .touchUpInside)
        buttonRight?.addTarget(self, action: #selector(handleButtonCenterTap), for: .touchUpInside)
        buttonCenter?.addTarget(self, action: #selector(handleButtonCenterTap), for: .touchUpInside)
        view.backgroundColor = Asset.Colors.myWhite.color
        view.addSubviews(screenTitle, container, screenButtons)
        
        if let buttonLeft, let buttonRight  {
            screenButtons.addArrangedSubview(buttonLeft)
            screenButtons.addArrangedSubview(buttonRight)
        }
        
        if let buttonCenter {
            screenButtons.addArrangedSubview(buttonCenter)
        }
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate(
            [
                screenTitle.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: UIConstants.nameLabelTopInset
                ),
                screenTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        )
        
        NSLayoutConstraint.activate(
            [
                container.topAnchor.constraint(
                    equalTo: screenTitle.bottomAnchor,
                    constant: UIConstants.containerToTitleInset
                ),
                container.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: .leadingInset
                ),
                container.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: .trailingInset
                ),
                container.bottomAnchor.constraint(equalTo: screenButtons.topAnchor)
            ]
        )
        
        NSLayoutConstraint.activate(
            [
                screenButtons.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: UIConstants.leading
                ),
                screenButtons.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: UIConstants.trailing
                ),
                screenButtons.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: UIConstants.bottom
                ),
                screenButtons.heightAnchor.constraint(equalToConstant: .buttonsHeight)
            ]
        )
    }
}
