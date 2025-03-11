//
//  TrackType.swift
//  Tracker
//
//  Created by Александр Зиновьев on 25.08.2024.
//

import Foundation
import TrackerDomain

enum TrackType: TrackableEvent {
    case trackers(event: TrackersEvent)
}
