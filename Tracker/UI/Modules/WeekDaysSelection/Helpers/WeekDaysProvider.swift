//
//  WeekDaysProvider.swift
//  Tracker
//
//  Created by Александр Зиновьев on 29.03.2025.
//

import Foundation
import TrackerDomain

struct WeekDaysProvider {
    let calendar: Calendar = .autoupdatingCurrent
    
    func getWeekDays() -> [WeekDay] {
        if calendar.firstWeekday == 2 {
            WeekDay.allCases
        }
        else {
            [
                .sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday
            ]
        }
    }
}
