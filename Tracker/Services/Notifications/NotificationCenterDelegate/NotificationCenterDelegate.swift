//
//  NotificationCenterDelegate.swift
//  Tracker
//
//  Created by Александр Зиновьев on 28.08.2025.
//

import Foundation
import UserNotifications

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
        completionHandler()
        
        let request = response.notification.request
        
        if
            let type = request.content.userInfo["type"] as? String,
            let notificationType = NotificationType(rawValue: type)
        {
            notificationDeepLinkService.handle(context: NotificationDeepLinkContext(type: notificationType))
        }
    }
}
