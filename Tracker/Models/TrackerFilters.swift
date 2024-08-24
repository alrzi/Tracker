//
//  Filter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 13.07.2024.
//

import Foundation

enum TrackerFilters: CaseIterable, Codable {
    case forCurrentWeekDay
    case completedForDate
    case uncompletedForDate
}

extension TrackerFilters: CustomStringConvertible {
    var description: String {
        switch self {        
        case .forCurrentWeekDay: Strings.Localizable.Filters.today
        case .completedForDate: Strings.Localizable.Filters.completed
        case .uncompletedForDate: Strings.Localizable.Filters.notCompleted
        }
    }
}
