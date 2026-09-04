//
//  TrackerNotificationInformation.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 3/19/26.
//

import Foundation

public struct TrackerNotificationInformation: Equatable, Hashable, Sendable {
    public let trackerId: UUID
    /// Общий рубильник уведомлений для этого трекера
    public let isGlobalEnabled: Bool
    /// Расписание: для каждого дня свой статус и время
    public let schedule: [WeekDay: DayNotificationDetails]

    public init(
        trackerId: UUID,
        isGlobalEnabled: Bool,
        schedule: [WeekDay: DayNotificationDetails]
    ) {
        self.trackerId = trackerId
        self.isGlobalEnabled = isGlobalEnabled
        self.schedule = schedule
    }

    /// Вложенная сущность для настроек конкретного дня
    public struct DayNotificationDetails: Equatable, Hashable, Sendable {
        public let weekDay: WeekDay
        public let isEnabled: Bool
        public let time: Date

        public init(weekDay: WeekDay, isEnabled: Bool, time: Date) {
            self.weekDay = weekDay
            self.isEnabled = isEnabled
            self.time = time
        }
    }
}
