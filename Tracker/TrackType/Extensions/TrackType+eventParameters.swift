//
//  TrackType+eventParameters.swift
//  Tracker
//
//  Created by Александр Зиновьев on 25.08.2024.
//

import Foundation

extension TrackType {
    var properties: [AnyHashable: Any]? {
        switch self {
        case .trackers(let event):
            return event.parameters
        }
    }
}
