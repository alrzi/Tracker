//
//  NotificationCenterDelegate.swift
//  Tracker
//
//  Created by Александр Зиновьев on 28.08.2025.
//

import Foundation
import UserNotifications
import Notifications

final class NotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let notificationDeepLinkService: NotificationDeepLinkServiceProtocol
    
    init(notificationDeepLinkService: NotificationDeepLinkServiceProtocol) {
        self.notificationDeepLinkService = notificationDeepLinkService
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.list, .banner, .badge, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let content = response.notification.request.content
        let payload: NotificationPayload<NotificationCategory>? = content.payload()

        if let payload {
            switch payload.category {
            case .trackers:
                debugPrint(payload.id)

            case .newTrackerCreation:
                debugPrint(payload.id)
                let service = notificationDeepLinkService

                Task {
                    await service.handle(context: NotificationDeepLinkContext(type: .newTrackerCreation))
                }
            }
        }

        completionHandler()
    }
}
