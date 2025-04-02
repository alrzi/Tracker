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
        case .monday: R.string.localizable.scheduleMon()
        case .tuesday: R.string.localizable.scheduleTue()
        case .wednesday: R.string.localizable.scheduleWed()
        case .thursday: R.string.localizable.scheduleThu()
        case .friday: R.string.localizable.scheduleFri()
        case .saturday: R.string.localizable.scheduleSat()
        case .sunday: R.string.localizable.scheduleSun()
        }
    }
    
    var abbreviationShort: String {
        switch self {
        case .monday: R.string.localizable.scheduleMon()
        case .tuesday: R.string.localizable.scheduleTue()
        case .wednesday: R.string.localizable.scheduleWed()
        case .thursday: R.string.localizable.scheduleThu()
        case .friday: R.string.localizable.scheduleFri()
        case .saturday: R.string.localizable.scheduleSat()
        case .sunday: R.string.localizable.scheduleSun()
        }
    }
}
