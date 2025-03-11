//
//  TrackersEvent.swift
//  Tracker
//
//  Created by Александр Зиновьев on 25.08.2024.
//

import Foundation
import TrackerDomain

enum TrackersEvent {
    case onAppear
    case action(Action)
}

extension TrackersEvent {
    enum Action {
        case onAddTracker
        case onDateChange
        case onChooseFilter
        case onTextSearch
        case onTrackerEdit
        case onTrackerPin
        case onTrackerDelete
    }
}

extension TrackersEvent: TrackingEvent {
    var name: String {
        switch self {
        case .action: "Trackers Screen Actions"
        case .onAppear: "Trackers Screen Appear"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .onAppear:
            nil
            
        case .action(let action):
            [
                "action": action.trackTitle
            ]
        }
    }
}

extension TrackersEvent.Action: TrackableType {
    var trackTitle: String {
        switch self {
        case .onAddTracker: "add tracker button tap"
        case .onDateChange: "date changed"
        case .onChooseFilter: "choose filter"
        case .onTextSearch: "text search"
        case .onTrackerEdit: "edit tracker"
        case .onTrackerPin: "pin tracker"
        case .onTrackerDelete: "delete tracker"
        }
    }
}
