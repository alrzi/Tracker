//
//  WeekDay+weeklyComponents.swift
//  Tracker
//
//  Created by Александр Зиновьев on 3/20/26.
//

import Foundation
import TrackerDomain

extension WeekDay {
    func weeklyComponents(from time: Date) -> DateComponents {
        let timeData = time.timeComponents
        return DateComponents(
            hour: timeData.hour,
            minute: timeData.minute,
            weekday: self.systemRawValue
        )
    }
}
