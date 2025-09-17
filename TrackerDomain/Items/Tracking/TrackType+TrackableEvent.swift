//
//  TrackType+TrackableEvent.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 16.04.2025.
//

import Foundation

extension TrackType: TrackableEvent {
    public var name: String {
        switch self {
        case .trackers(let event): event.name
        }
    }
    
    public var properties: [AnyHashable: Any]? {
        switch self {
        case .trackers(let event): event.properties
        }
    }
}
