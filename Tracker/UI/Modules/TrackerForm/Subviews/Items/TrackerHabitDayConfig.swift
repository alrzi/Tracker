//
//  TrackerHabitDayConfig.swift
//  Tracker
//
//  Created by Александр Зиновьев on 3/14/26.
//

import Foundation
import TrackerDomain

struct TrackerHabitDayConfig: Equatable {
    let day: WeekDay
    var isSelected: Bool
    var notification: NotificationInfo

    init(
        day: WeekDay,
        isSelected: Bool,
        details: TrackerNotificationInformation.DayNotificationDetails?
    ) {
        self.day = day
        self.isSelected = isSelected
        self.notification = NotificationInfo(
            isEnabled: details?.isEnabled ?? false,
            time: details?.time ?? Date()
        )
    }

    mutating func toggleSelection() {
        isSelected.toggle()
        if !isSelected {
            notification.isEnabled = false
        }
    }

    mutating func setNotification(enabled: Bool) {
        notification.isEnabled = enabled
        if enabled {
            isSelected = true
        }
    }

    mutating func updateTime(_ newTime: Date) {
        notification.time = newTime
        notification.isEnabled = true
        isSelected = true
    }
}

extension TrackerHabitDayConfig {
    struct NotificationInfo: Equatable {
        var isEnabled: Bool
        var time: Date
    }
}

extension Array where Element == TrackerHabitDayConfig {
    func extractSchedule() -> [WeekDay: Date] {
        reduce(into: [:]) { result, config in
            if config.notification.isEnabled {
                result[config.day] = config.notification.time
            }
        }
    }
}
