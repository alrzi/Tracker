//
//  TrackerFilters+description.swift
//  Tracker
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation
import TrackerDomain

extension TrackerFilters: CustomStringConvertible {
    public var description: String {
        switch self {
        case .forCurrentWeekDay: "Strings.Localizable.Filters.today"
        case .completedForDate: "Strings.Localizable.Filters.completed"
        case .uncompletedForDate: "Strings.Localizable.Filters.notCompleted"
        }
    }
}
