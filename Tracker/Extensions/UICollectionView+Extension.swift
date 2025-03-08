import UIKit

extension UICollectionView {
    // MARK: - Dequeue
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(
            withReuseIdentifier: T.reuseIdentifier,
            for: indexPath
        ) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        
        return cell
    }
    
    func dequeueFooter<T: UICollectionReusableView>(ofKind kind: String, for indexPath: IndexPath) -> T {
        guard let footer = dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: T.reuseIdentifier,
            for: indexPath
        ) as? T
        else {
            fatalError("Could not dequeue footer with identifier: \(T.reuseIdentifier)")
        }
        return footer
    }
    
    func dequeueHeader<T: UICollectionReusableView>(ofKind kind: String, for indexPath: IndexPath) -> T {
        guard let header = dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: T.reuseIdentifier,
            for: indexPath
        ) as? T
        else {
            fatalError("Could not dequeue header with identifier: \(T.reuseIdentifier)")
        }
        return header
    }
    
    // MARK: - Register
    func register<T: UICollectionViewCell>(cellClass: T.Type) {
        register(cellClass, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func registerHeader<T: UICollectionReusableView>(_: T.Type) {
        register(
            T.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: T.reuseIdentifier
        )
    }
    
    func registerFooter<T: UICollectionReusableView>(_: T.Type) {
        register(
            T.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: T.reuseIdentifier
        )
    }
    
    // MARK: - GetCell
    func cellForItem<T: UICollectionViewCell>(ofType cellType: T.Type, at indexPath: IndexPath) -> T {
        guard let cell = self.cellForItem(at: indexPath) as? T
        else {
            fatalError("Could not dequeue UICollectionViewCell with identifier: \(T.reuseIdentifier)")
        }
        
        return cell
    }
}

extension UICollectionView {
    func deselectOldSelectNewCellOf<T: Highilable>(
        type: T.Type,
        _ previouslySelectedIndexPath: IndexPath?,
        configureSelectedCell: ((String?) -> Void)? = nil
    ) {
        // if cell selected first time
        if let newIndexPath = self.indexPathsForSelectedItems?.first {
            guard let previouslySelectedIndexPath else {
                if let cell = self.cellForItem(at: newIndexPath) as? T {
                    cell.highlight()
                    configureSelectedCell?(cell.content)
                }
                return
            }
            // If new selected cell is not same as previous selected
            if previouslySelectedIndexPath != newIndexPath {
                deselectItem(at: previouslySelectedIndexPath, animated: false)
                if let cell = self.cellForItem(at: previouslySelectedIndexPath) as? T {
                    cell.unhighlight()
                }
               
                if let cell = self.cellForItem(at: newIndexPath) as? T {
                    cell.highlight()
                    configureSelectedCell?(cell.content)
                }
                // If new selected cell is same as previous selected
            } 
            else {
                if let cell = self.cellForItem(at: newIndexPath) as? T {
                    if cell.toggle() {
                        configureSelectedCell?(nil)
                    } 
                    else {
                        configureSelectedCell?(cell.content)
                    }
                }
            }
        }
    }
}
