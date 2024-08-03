import UIKit

extension UIView {
    static var reuseIdentifier: String {
        String(describing: self)
    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach {
            if let stackView = self as? UIStackView {
                stackView.addArrangedSubview($0)
            } 
            else {
                addSubview($0)
            }
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func shakeSelf() {
        let shakingAnimation = CABasicAnimation(keyPath: "position")
        shakingAnimation.duration = 0.05
        shakingAnimation.repeatCount = 5
        shakingAnimation.autoreverses = true
        
        let fromPoint = CGPoint(x: self.center.x - 4, y: self.center.y)
        let toPoint = CGPoint(x: self.center.x + 4, y: self.center.y)
        
        shakingAnimation.fromValue = NSValue(cgPoint: fromPoint)
        shakingAnimation.toValue = NSValue(cgPoint: toPoint)
        
        self.layer.add(shakingAnimation, forKey: nil)
    }
}
