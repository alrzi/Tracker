//
//  AnalyticsTracking.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation

public protocol AnalyticsTracking {
    func track(event: TrackableEvent)
}

/// Событие отслеживания
public protocol TrackableEvent {
    /// Название события
    var name: String { get }
    
    /// Свойства события
    var properties: [AnyHashable: Any]? { get }
}

public protocol TrackingEvent {
    var name: String { get }
    var parameters: [String: Any]? { get }
}

public protocol TrackableType {
    var trackTitle: String { get }
}
