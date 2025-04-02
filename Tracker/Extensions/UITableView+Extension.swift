import UIKit

extension UITableViewCell {
    static var reuseIdentifier: String {
        String(describing: self)
    }
    
    // MARK: - Public
    func setSeparatorInset(in tableView: UITableView, at indexPath: IndexPath) {
        if tableView.cellIsOnlyOne(at: indexPath) {
            tableView.separatorInset = UIEdgeInsets(
                top: .zero,
                left: .zero,
                bottom: .zero,
                right: tableView.bounds.width
            )
        }
        else if tableView.cellIsLast(at: indexPath) {
            tableView.separatorInset = UIEdgeInsets(
                top: .zero,
                left: .zero,
                bottom: .zero,
                right: tableView.bounds.width
            )
        }
        else {
            tableView.separatorInset = UIEdgeInsets(
                top: .zero,
                left: 16,
                bottom: .zero,
                right: 16
            )
        }
    }
    
    func setCorners(in tableView: UITableView, at indexPath: IndexPath, radius: CGFloat = 12) {
        let corners: CACornerMask
        
        if tableView.cellIsOnlyOne(at: indexPath) {
            corners = CACornerMask(allCorners: true)
        } 
        else if tableView.cellIsFirst(at: indexPath){
            corners = CACornerMask(topCorners: true)
        } 
        else if tableView.cellIsLast(at: indexPath) {
            corners = CACornerMask(bottomCorners: true)
        } 
        else {
            corners = []
        }
        
        set(corners, with: radius)
    }
    
    // MARK: - Private
    private func set(_ corners: CACornerMask, with radius: CGFloat) {
        self.contentView.layer.cornerRadius = radius
        self.contentView.layer.maskedCorners = [corners]
    }
}

extension UITableView {
    // MARK: - Public
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(
            withIdentifier: T.reuseIdentifier,
            for: indexPath
        ) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        
        return cell
    }
    
    func register<T: UITableViewCell>(cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func cellIsFirst(at indexPath: IndexPath) -> Bool {
        indexPath.row == 0
    }
    
    func cellIsLast(at indexPath: IndexPath) -> Bool {
        indexPath.row == numberOfRows(inSection: indexPath.section) - 1
    }
    
    func cellIsOnlyOne(at indexPath: IndexPath) -> Bool {
        numberOfRows(inSection: indexPath.section) == 1
    }
}

extension CACornerMask {
    init(topCorners: Bool = false, bottomCorners: Bool = false, allCorners: Bool = false) {
        if allCorners {
            self = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        else {
            var mask: CACornerMask = []
            if topCorners {
                mask.insert(.layerMinXMinYCorner)
                mask.insert(.layerMaxXMinYCorner)
            }
            if bottomCorners {
                mask.insert(.layerMinXMaxYCorner)
                mask.insert(.layerMaxXMaxYCorner)
            }
            self = mask
        }
    }
}
