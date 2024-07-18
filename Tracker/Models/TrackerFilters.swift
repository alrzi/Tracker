//
//  Filter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 13.07.2024.
//

import Foundation

enum TrackerFilters: CaseIterable {
    case all
    case forToday
    case completed
    case uncompleted
}

extension TrackerFilters: CustomStringConvertible {
    var description: String {
        switch self {
        case .all: Strings.Localizable.Filters.all
        case .forToday: Strings.Localizable.Filters.today
        case .completed: Strings.Localizable.Filters.completed
        case .uncompleted: Strings.Localizable.Filters.notCompleted
        }
    }
}
