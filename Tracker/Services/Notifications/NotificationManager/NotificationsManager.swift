//
//  NotificationsManager.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.08.2025.
//

import Foundation
import UserNotifications

protocol NotificationsManaging {
    var status: ReadOnlyObservableWrapper<NotificationsPermissionState> { get }
    
    func updatePermissionState(requestIfUndefined: Bool) async throws(NotificationsError) -> NotificationsPermissionState
    func scheduleNotification(request: UNNotificationRequest) async throws(NotificationsError)
    func cancelNotification(identifier: String) async
    func fetchScheduledNotifications() async -> [UNNotificationRequest]
}

final class NotificationsManager: NotificationsManaging, Sendable {
    private var notificationCenter: UNUserNotificationCenter { UNUserNotificationCenter.current() }
    
    private let mutableStatus: ObservableActor<NotificationsPermissionState> = .init(.unknown)
    let status: ReadOnlyObservableWrapper<NotificationsPermissionState>
    
    init() {
        status = mutableStatus.readOnly()
    }
    
    func updatePermissionState(requestIfUndefined: Bool) async throws(NotificationsError) -> NotificationsPermissionState {
        let status = await requestPermissionStatus()
        
        let newStatus: NotificationsPermissionState
        
        if requestIfUndefined, case .unknown = status {
            let isGranted = try await requestPermission()
            
            newStatus = isGranted ? .granted: .denied
        }
        else {
            newStatus = status
        }
        
        await mutableStatus.setIfNeeded(value: newStatus)
        
        return newStatus
    }
    
    func scheduleNotification(request: UNNotificationRequest) async throws(NotificationsError) {
        do {
            try await notificationCenter.add(request)
        }
        catch {
            throw NotificationsError.schedulingFailed(error)
        }
    }
    
    func cancelNotification(identifier: String) async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func fetchScheduledNotifications() async -> [UNNotificationRequest] {
        await notificationCenter.pendingNotificationRequests()
    }
    
    func checkNotificationSettings() async -> String {
        let settings = await notificationCenter.notificationSettings()
        
        return settings.authorizationStatus.title
    }
}

// MARK: - Private

private extension NotificationsManager {
    func requestPermissionStatus() async -> NotificationsPermissionState {
        let settings = await notificationCenter.notificationSettings()
        
        return settings.authorizationStatus.toState()
    }
    
    func requestPermission() async throws(NotificationsError) -> Bool {
        do {
            let isGranted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge, .provisional])
            
            return isGranted
        }
        catch {
            throw NotificationsError.requestAuthorization(error)
        }
    }
}

private extension UNAuthorizationStatus {
    var title: String {
        switch self {
        case .authorized: "Notifications are authorized."
        case .denied: "Notifications are denied."
        case .provisional: "Notifications are provisionally authorized."
        case .notDetermined: "Notifications permission not determined."
        case .ephemeral: "Notifications are ephemeral."
        default: "Unknown notification status."
        }
    }
    
    func toState() -> NotificationsPermissionState {
        switch self {
        case .authorized, .provisional, .ephemeral: .granted
        case .notDetermined: .unknown
        case .denied: .denied
        @unknown default: .unknown
        }
    }
}
