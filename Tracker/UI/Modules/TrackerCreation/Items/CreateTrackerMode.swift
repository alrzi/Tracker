//
//  CreateTrackerMode.swift
//  Tracker
//
//  Created by Александр Зиновьев on 29.07.2024.
//

import Foundation

enum CreateTrackerMode {
    case create(TrackerKind)
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
