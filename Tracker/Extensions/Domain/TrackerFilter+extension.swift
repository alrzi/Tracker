//
//  TrackerFilter+extension.swift
//  Tracker
//
//  Created by Александр Зиновьев on 19.03.2025.
//

import Foundation
import TrackerDomain

extension TrackerFilter {
    var name: String {
        switch self {
        case .completedForDate: "Completed"
        case .forCurrentWeekDay: "All"
        case .uncompletedForDate: "In progress"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .completedForDate: "checklist.checked"
        case .forCurrentWeekDay: "xmark.triangle.circle.square"
        case .uncompletedForDate: "checklist.unchecked"
        }
    }
}
