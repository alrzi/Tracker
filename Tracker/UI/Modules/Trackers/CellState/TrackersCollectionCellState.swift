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
    var pinnedSection: TrackerSection?
    var notPinnedSections: [TrackerSection]?
}
 
extension TrackersCollectionCellState {
    typealias SectionIdentifier = TrackersSectionID
    typealias ItemIdentifier = TrackersSectionItemID
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>
    
    static let empty: Self = .init()
    
    private var sections: [SectionIdentifier] {
        var sectionIdentifiers: [SectionIdentifier] = []
        
        if pinnedSection != nil {
            sectionIdentifiers.append(.pinned)
        }
        
        if let notPinnedSections {
            notPinnedSections.enumerated().forEach {
                sectionIdentifiers.append(.notPinned($0.offset, $0.element.id))
            }
        }
        
        return sectionIdentifiers
    }
    
    var snapshot: Snapshot {
        var snapshot = Snapshot()
        
        if let pinnedSection {
            snapshot.appendSections([.pinned])
            snapshot.appendItems(pinnedSection.trackers.map { .tracker($0.id) }, toSection: .pinned)
        }
        
        if let notPinnedSections {
            notPinnedSections.enumerated().forEach {
                snapshot.appendSections([.notPinned($0.offset, $0.element.id)])
                snapshot.appendItems($0.element.trackers.map { .tracker($0.id) }, toSection: .notPinned($0.offset, $0.element.id))
            }
        }
        
        return snapshot
    }
    
    func item(at indexPath: IndexPath) -> Tracker? {
        guard let sectionID = sections.elementOrNil(at: indexPath.section) else {
            return nil
        }
        
        switch sectionID {
        case .pinned:
            let tracker = pinnedSection?.trackers.elementOrNil(at: indexPath.item)
            
            return tracker
            
        case .notPinned(let index, _):
            let section = notPinnedSections?.elementOrNil(at: index)
            let tracker = section?.trackers.elementOrNil(at: indexPath.item)
            
            return tracker
        }
    }
    
    func sectionTitle(at indexPath: IndexPath) -> String? {
        guard let sectionID = sections.elementOrNil(at: indexPath.section) else {
            return nil
        }
        
        switch sectionID {
        case .pinned:
            return pinnedSection?.title
            
        case .notPinned(let index, _):
            let section = notPinnedSections?.elementOrNil(at: index)
           
            return section?.title
        }
    }
}
