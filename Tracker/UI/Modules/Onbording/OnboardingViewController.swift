import UIKit

final class OnboardingViewController: UIViewController {
    // MARK: - Private properties
    private let imageView = UIImageView()
    private let greetingLabel: UILabel = {
        let greetingLabel = UILabel()
        greetingLabel.numberOfLines = 0
        greetingLabel.textAlignment = .center
        greetingLabel.textColor = .black
        greetingLabel.font = .bold32
        greetingLabel.lineBreakMode = .byWordWrapping
        return greetingLabel
    }()
    
    // MARK: - Init
    init(image: UIImage?, greetingText: String) {
        self.imageView.image = image
        self.greetingLabel.text = greetingText
        super.init(nibName: nil, bundle: nil)
        
        imageView.contentMode = .scaleAspectFill
    }
       
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
}

// MARK: - Private methods
private extension OnboardingViewController {
    func setupLayout() {
        view.addSubviews(imageView, greetingLabel)
        
        NSLayoutConstraint.activate([
            greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .leadingInset),
            greetingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: .trailingInset),
            greetingLabel.topAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
}
