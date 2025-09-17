//
//  TrackersCollectionOutput.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import Foundation
import TrackerDomain

enum TrackersCollectionOutput {
    case togglePin(Tracker)
    case delete(Tracker)
    case edit(Tracker)
}
