//
//  TrackType.swift
//  Tracker
//
//  Created by Александр Зиновьев on 25.08.2024.
//

import Foundation

/// Событие отслеживания
public protocol TrackableEvent {
    /// Название события
    var name: String { get }
    
    /// Свойства события
    var properties: [AnyHashable: Any]? { get }
}

protocol TrackingEvent {
    var name: String { get }
    var parameters: [String: Any]? { get }
}

protocol TrackableType {
    var trackTitle: String { get }
}


enum TrackType: TrackableEvent {
    case trackers(event: TrackersEvent)
}
