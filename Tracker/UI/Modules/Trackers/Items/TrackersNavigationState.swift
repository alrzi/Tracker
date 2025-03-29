//
//  TrackersNavigationState.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.03.2025.
//

import Foundation
import TrackerDomain

@MainActor
protocol TrackersNavigationState: ObservableObject {
    var route: TrackersRoute? { get set }
}

enum TrackersRoute: Identifiable {
    case update(Tracker, onCompletion: (TrackerSection) -> Void)
    case create(onCompletion: (TrackerSection) -> Void)
    
    var id: ID {
        switch self {
        case .update: .update
        case .create: .create
        }
    }
    
    enum ID {
        case update
        case create
    }
}
