//
//  Date+fullDayInterval.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 09.04.2025.
//

import Foundation

extension Date {
    func fullDayInterval(calendar: Calendar = .autoupdatingCurrent) -> DateInterval {
        let startDate = calendar.startOfDay(for: self)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? self
        
        return DateInterval(start: startDate, end: endDate)
    }
}
