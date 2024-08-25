//
//  TrackType+eventName.swift
//  Tracker
//
//  Created by Александр Зиновьев on 25.08.2024.
//

import Foundation

extension TrackType {
    var name: String {
        switch self {
        case .trackers(let event): event.name
        }
    }
}
