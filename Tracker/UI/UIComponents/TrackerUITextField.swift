import UIKit

protocol TrackerUITextFieldDelegate: AnyObject {
    func isChangeText(text: String, newLength: Int) -> Bool?
}

final class TrackerUITextField: UIView {
    // MARK: - Delegate
    weak var delegate: TrackerUITextFieldDelegate?
    
    // MARK: - Private properties
    private var textField: UITextField = {
        let view = UITextField()
        // Style
        view.font = .regular17
        view.textColor = .black
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = .cornerRadius
        view.layer.masksToBounds = true
        
        // Insets
        let rect = CGRect(x: .zero, y: .zero, width: 16, height: view.frame.height)
        let insetView = UIView(frame: rect)
        view.leftView = insetView
        view.leftViewMode = .always
        view.rightView = insetView
        view.rightViewMode = .always
        return view
    }()
    
    // MARK: - Init
    init(text: String) {
        textField.placeholder = text
        super.init(frame: .zero)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    func set(text: String?) {
        textField.text = text
    }
    
    func hideKeyBoard() {
        textField.resignFirstResponder()
    }
}

// MARK: - Private Methods
private extension TrackerUITextField {
    func setupUI() {
        addSubviews(textField)
        textField.delegate = self
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: .cellHeight)
        ])
    }
    
    func activateKeyboardFromBottom() {
        self.becomeFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension TrackerUITextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let myTextField = textField as? TrackerUITextField {
            myTextField.activateKeyboardFromBottom()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        let newLength = currentText.count + string.count - range.length
        return delegate?.isChangeText(text: updatedText, newLength: newLength) ?? true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
