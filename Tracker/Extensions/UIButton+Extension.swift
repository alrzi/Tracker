import UIKit

class ExtendedButton: UIButton {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let extendedArea = UIEdgeInsets(top: -50, left: -50, bottom: -50, right: -50)
        let extendedBounds = bounds.inset(by: extendedArea)
        return extendedBounds.contains(point) ? self : nil
    }
}
