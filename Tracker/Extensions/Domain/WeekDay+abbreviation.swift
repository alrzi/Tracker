//
//  WeekDay+abbreviation.swift
//  Tracker
//
//  Created by Александр Зиновьев on 29.03.2025.
//

import Foundation
import TrackerDomain

extension WeekDay {
    var abbreviationLong: String {
        switch self {
        case .monday: String(localized: .scheduleMonday)
        case .tuesday: String(localized: .scheduleTuesday)
        case .wednesday: String(localized: .scheduleWednesday)
        case .thursday: String(localized: .scheduleThursday)
        case .friday: String(localized: .scheduleFriday)
        case .saturday: String(localized: .scheduleSaturday)
        case .sunday: String(localized: .scheduleSunday)
        }
    }
    
    var abbreviationShort: String {
        switch self {
        case .monday: String(localized: .scheduleMon)
        case .tuesday: String(localized: .scheduleTue)
        case .wednesday: String(localized: .scheduleWed)
        case .thursday: String(localized: .scheduleThu)
        case .friday: String(localized: .scheduleFri)
        case .saturday: String(localized: .scheduleSat)
        case .sunday: String(localized: .scheduleSun)
        }
    }
}
