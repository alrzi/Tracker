import UIKit

final class SplashViewController: UIViewController {
    // MARK: Private properties
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Asset.Assets._07Logo.image
        return imageView
    }()
    
    private let viewModel: SplashViewModel

    // MARK: - Init
    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        start()
    }
    
    func setLayout() {
        view.addSubviews(imageView)
        view.backgroundColor = Asset.Colors.myBlue.color
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func start() {
        if viewModel.isUserLoggedIn() {
            presentTrackerViewcontroller()
        } else {
            let onboardingPageViewController = OnboardingPageViewController()
            onboardingPageViewController.modalPresentationStyle = .overFullScreen
            onboardingPageViewController.modalTransitionStyle = .crossDissolve
            present(onboardingPageViewController, animated: true)
           
            onboardingPageViewController.userSuccessfullyLoggedIn = { [weak self] in
                guard let self = self else { return }
                self.viewModel.loginUser {
                    self.presentTrackerViewcontroller()
                }
            }
        }
    }
    
    private func presentTrackerViewcontroller() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        
        let tabBar = MainTabBarController()
        window.rootViewController = tabBar
    }
}
