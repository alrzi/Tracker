//
//  TrackersDataSource.swift
//  Tracker
//
//  Created by Александр Зиновьев on 13.07.2024.
//

import UIKit

extension TrackersDataSource {
    enum Section: Hashable {
        case pinnedTrackers(String)
        case trackers(String)
    }
    
    enum SectionItem: Hashable {
        case pinnedTrackers(Tracker)
        case trackers(Tracker)
    }
}

final class TrackersDataSource: UICollectionViewDiffableDataSource
<TrackersDataSource.Section, TrackersDataSource.SectionItem> {
    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .pinnedTrackers(let tracker):
                let cell: TrackerCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.configure(with: tracker)
                return cell
            
            case .trackers(let tracker):
                let cell: TrackerCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.configure(with: tracker)
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
        
        let section = snapshot().sectionIdentifiers[indexPath.section]
        
        switch section {
        case .pinnedTrackers(let headerString):
            header.configure(with: headerString)
        
        case .trackers(let headerString):
            header.configure(with: headerString)
        }
        
        return header
    }

    func reload(_ data: [TrackerCategory], animated: Bool = true) {
        var snapshot = snapshot()
        
        for section in data {
            snapshot.appendSections([.trackers(section.header)])
            snapshot.appendItems(section.trackers.map { .trackers($0) }, toSection: .trackers(section.header))
        }
        
        apply(snapshot, animatingDifferences: animated)
    }
    
    func reload(_ data: TrackerCategory, animated: Bool = true) {
        var snapshot = snapshot()
        
        snapshot.appendSections([.pinnedTrackers(data.header)])
        snapshot.appendItems(data.trackers.map { .pinnedTrackers($0) }, toSection: .pinnedTrackers(data.header))
        
        apply(snapshot, animatingDifferences: animated)
    }
}
