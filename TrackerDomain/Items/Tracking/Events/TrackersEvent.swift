//
//  TrackersEvent.swift
//  Tracker
//
//  Created by Александр Зиновьев on 25.08.2024.
//

import Foundation

public enum TrackersEvent {
    case onAppear
    case action(Action)
    
    public enum Action {
        case onAddTracker
        case onDateChange
        case onChooseFilter
        case onTextSearch
        case onTrackerEdit
        case onTrackerPin
        case onTrackerDelete
    }
}

extension TrackersEvent: TrackableEvent {
    public var name: String {
        switch self {
        case .action: "Trackers Screen Actions"
        case .onAppear: "Trackers Screen Appear"
        }
    }
    
    public var properties: [AnyHashable: Any]? {
        switch self {
        case .onAppear:
            return nil
            
        case .action(let action):
            return [
                "action": action.trackValue
            ]
        }
    }
}

extension TrackersEvent.Action: TrackableType {
    public var trackValue: String {
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
