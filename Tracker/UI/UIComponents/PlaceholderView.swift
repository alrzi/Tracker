import UIKit

final class PlaceholderView: UIView {
    // MARK: - Public
    var state: PlaceholderState = .question {
        didSet {
            updateAppearance()
        }
    }
    
    enum PlaceholderState {
        case question, noResult, noStatistic, recomendation
        case invisible(animate: Bool)
    }

    enum Placeholder {
        case star
        case noResult
        case noStatistic

        var image: UIImage? {
            switch self {
            case .star:
                return Asset.Assets._05placeholderTracker.image
            
            case .noResult:
                return Asset.Assets._13placeholderNoResult.image
            
            case .noStatistic:
                return Asset.Assets._12placeholderNoStatistic.image
            }
        }
    }
    
    // MARK: - UIConstants
    private enum UIConstants {
        static let placeholderText: CGFloat = 12
        static let textToImageOffset: CGFloat = 8
        static let imageSize: CGFloat = 80
        static let halfImageSize = imageSize / 2
    }
    
    // MARK: - Private properties
    private let placeholderImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        return view
    }()
    
    private let placeholderText: UILabel = {
        let label = UILabel()
        label.font = .medium12
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Init
    init(state: PlaceholderState) {
        super.init(frame: .zero)
        self.state = state
        
        setupUI()
        updateAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
}

// MARK: - Private methods
private extension PlaceholderView {
    func setupUI() {
        addSubviews(placeholderText, placeholderImageView)
                
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            placeholderImageView.heightAnchor.constraint(equalToConstant: UIConstants.imageSize),
            placeholderImageView.widthAnchor.constraint(equalToConstant: UIConstants.imageSize)
        ])
        
        NSLayoutConstraint.activate(
            [
                placeholderText.centerXAnchor.constraint(equalTo: centerXAnchor),
                placeholderText.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .leadingInset),
                placeholderText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: .trailingInset),
                placeholderText.topAnchor.constraint(
                    equalTo: placeholderImageView.bottomAnchor,
                    constant: UIConstants.textToImageOffset
                )
            ]
        )
    }
    
    func updateAppearance() {
        switch state {
        case .invisible(let isAnimate):
            isAnimate ? setAlphaToZero() : setAlphaToZero(time: .zero)
        
        case .question:
            setState(image: .star, text: Strings.Localizable.Placeholder.question)
        
        case .noResult:
            setState(image: .noResult, text: Strings.Localizable.Placeholder.noResults)
        
        case .noStatistic:
            setState(image: .noStatistic, text: Strings.Localizable.Placeholder.noStatistic)
        
        case .recomendation:
            setState(image: .star, text: Strings.Localizable.Placeholder.recomendation)
        }
    }
    
    func setState(image: Placeholder, text: String) {
        setAlphaToZero()
        setImageAndText(placeholder: image, text: text)
        setAlphaToOne()
    }
    
    func setImageAndText(placeholder: Placeholder, text: String) {
        placeholderImageView.image = placeholder.image
        placeholderText.text = text
    }
    
    func setAlphaToOne() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    func setAlphaToZero(time: Double = 0.3) {
        UIView.animate(withDuration: time) {
            self.alpha = .zero
        }
    }
}
