//
//  TrackerNotificationProvider.swift
//  Tracker
//
//  Created by Александр Зиновьев on 3/20/26.
//

import Foundation
import TrackerDomain

struct TrackerNotificationProvider: AppNotificationProvider {
    let trackerManager: any TrackerManaging
    let category: NotificationCategory = .trackers

    func fetchNotifications() async -> [AppNotification] {
        guard let trackers = try? await trackerManager.fetchAllWithNotificationsInfo() else {
            return []
        }

        return trackers
            .filter { $0.notificationInformation?.isGlobalEnabled ?? false }
            .flatMap { Self.createNotifications(for: $0, in: category) }
    }
}

// MARK: - Private

private extension TrackerNotificationProvider {
    static func createNotifications(for tracker: Tracker, in category: NotificationCategory) -> [AppNotification] {
        guard let info = tracker.notificationInformation else {
            return []
        }

        return info.schedule.compactMap { day, details in
            guard details.isEnabled else {
                return nil
            }

            return AppNotification(
                id: tracker.id.uuidString,
                category: category,
                title: tracker.name,
                body: "Пора отметить прогресс! \(tracker.emoji)",
                trigger: .weekly(day.weeklyComponents(from: details.time))
            )
        }
    }
}
