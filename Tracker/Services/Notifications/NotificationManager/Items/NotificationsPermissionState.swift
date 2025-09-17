//
//  NotificationsPermissionState.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.08.2025.
//

import Foundation

enum NotificationsPermissionState: Sendable {
    case unknown
    case granted
    case denied
    
    var hasPermission: Bool {
        self == .granted
    }
}
