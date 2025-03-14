//
//  TrackersCollectionCellState.swift
//  Tracker
//
//  Created by Александр Зиновьев on 13.07.2024.
//

import Foundation
import UIKit
import TrackerDomain

struct TrackersCollectionCellState {
    var trackerSections: [TrackerSection] = []
}
 
extension TrackersCollectionCellState {
    typealias SectionIdentifier = TrackersSectionID
    typealias ItemIdentifier = TrackersSectionItemID
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>
    
    static let empty: Self = .init()
    
    var snapshot: Snapshot {
        var snapshot = Snapshot()
               
        trackerSections.enumerated().forEach {
            snapshot.appendSections([.sections($0.offset, $0.element.id)])
            snapshot.appendItems($0.element.trackers.map { .tracker($0.id) }, toSection: .sections($0.offset, $0.element.id))
        }
            
        return snapshot
    }
    
    func item(at indexPath: IndexPath) -> Tracker? {
        guard let section = snapshot.sectionIdentifiers.elementOrNil(at: indexPath.section) else {
            return nil
        }
               
        return switch section {
        case .sections(let index, _): trackerSections.elementOrNil(at: index)?.trackers.elementOrNil(at: indexPath.item)
        }
    }
    
    func sectionTitle(at indexPath: IndexPath) -> String? {
        guard let section = snapshot.sectionIdentifiers.elementOrNil(at: indexPath.section) else {
            return nil
        }
        
        return switch section {
        case .sections(let index, _): trackerSections.elementOrNil(at: index)?.title
        }
    }
}
