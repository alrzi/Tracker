//
//  CreateTrackerMode.swift
//  Tracker
//
//  Created by Александр Зиновьев on 29.07.2024.
//

import Foundation
import TrackerDomain

enum CreateTrackerMode {
    case create(Tracker.Kind)
    case update(Tracker, Date)
    
    var tracker: Tracker? {
        switch self {
        case .create: nil
        case .update(let tracker, _): tracker
        }
    }
    
    var date: Date? {
        switch self {
        case .create: nil
        case .update(_, let date): date
        }
    }
}
