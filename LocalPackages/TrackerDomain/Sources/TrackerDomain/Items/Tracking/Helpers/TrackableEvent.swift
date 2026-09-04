//
//  TrackableEvent.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 16.04.2025.
//

import Foundation

public protocol TrackableEvent {
    var name: String { get }
    var properties: [AnyHashable: Any]? { get }
}
