import UIKit

// MARK: - State
enum State {
    case selected
    case unselected
    
    mutating func toggle() -> Bool {
        switch self {
        case .selected:
            self = .unselected
            return true
        
        case .unselected:
            self = .selected
            return false
        }
    }
}

final class ActionButton: UIButton {
    // MARK: - ButtonColorType
    enum ColorType {
        case black, red, grey, trueBlack
    }
    
    var colorType: ColorType = .black {
        didSet {
            updateAppearance()
        }
    }
    
    // MARK: - ButtonState
    enum State {
        case enabled, disabled
    }
    
    var buttonState: State = .disabled {
        didSet {
            configureButton()
        }
    }
    
    private var title: String?

    // MARK: - Init
    init(
        type: UIButton.ButtonType = .system,
        colorType: ColorType,
        title: String
    ) {
        super.init(frame: .zero)
        self.colorType = colorType
        self.title = title
        updateAppearance()
    }
    
    convenience init(title: String) {
        self.init(colorType: .trueBlack, title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    private func updateAppearance() {
        layer.masksToBounds = true
        layer.cornerRadius = .cornerRadius
        titleLabel?.font = .medium16
        heightAnchor.constraint(equalToConstant: .buttonsHeight).isActive = true
       
        switch colorType {
        case .black:
            backgroundColor = Asset.Colors.myBlack.color
            setTitleColor(Asset.Colors.myWhite.color, for: .normal)
            setTitle(title, for: .normal)
        
        case .red:
            backgroundColor = Asset.Colors.myWhite.color
            layer.borderWidth = 1
            layer.borderColor = Asset.Colors.myRed.color.cgColor
            setTitleColor(Asset.Colors.myRed.color, for: .normal)
            setTitle(title, for: .normal)
        
        case .grey:
            backgroundColor = Asset.Colors.myGray.color
            setTitleColor(.white, for: .normal)
            setTitle(title, for: .normal)
        
        case .trueBlack:
            backgroundColor = .black
            setTitleColor(.white, for: .normal)
            setTitle(title, for: .normal)
        }
    }
    
    func configureButton() {
        switch buttonState {
        case .enabled:
            UIView.animate(withDuration: 0.3, delay: 0) {
                self.colorType = .black
            }
            
        case .disabled:
            UIView.animate(withDuration: 0.3, delay: 0) {
                self.colorType = .grey
            }
        }
    }
}
