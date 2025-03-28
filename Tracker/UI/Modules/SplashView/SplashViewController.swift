import UIKit

final class SplashViewController: UIViewController {
    // MARK: Private properties
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.logo()!
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
        view.backgroundColor = R.color.myBlue()
        
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func start() {
        viewModel.loginUser()
    }
}
