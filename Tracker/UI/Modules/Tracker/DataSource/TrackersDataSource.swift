//
//  TrackersDataSource.swift
//  Tracker
//
//  Created by Александр Зиновьев on 13.07.2024.
//

import UIKit
import CoreData.NSManagedObjectID

extension TrackersDataSource {
    enum Section: Hashable {
        case search
        case section(String)
    }
    
    enum SectionItem: Hashable {
        case tracker(NSManagedObjectID)
    }
}

final class TrackersDataSource: UICollectionViewDiffableDataSource
<TrackersDataSource.Section, TrackersDataSource.SectionItem> {
    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case .tracker(let id):
                
                
                let cell: TrackerCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
//                cell.configure(with: )
                return cell
            }
        }
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let header: TrackerCollectionHeader = collectionView.dequeueHeader(
            ofKind: UICollectionView.elementKindSectionHeader,
            for: indexPath
        )
        
//        let section = snapshot().sectionIdentifiers[indexPath.section]
//                       
//        switch section {
//        case .section(let title):
//            header.configure(with: title)
//        
//        case .search:
//            break
//        }
        
        return header
    }

    func reload(_ data: [TrackerCategory], animated: Bool = true) {
//        var snapshot = snapshot()
//        
//        for section in data {
//            snapshot.appendSections([.section(title: section.header)])
//            snapshot.appendItems(section.trackers.map { .tracker($0) }, toSection: .section(title: section.header))
//        }
//        
//        apply(snapshot, animatingDifferences: animated)
    }
}
