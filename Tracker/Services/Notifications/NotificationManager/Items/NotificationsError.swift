//
//  NotificationsError.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.08.2025.
//

import Foundation

enum NotificationsError: Error {
    case schedulingFailed(Error)
    case requestAuthorization(Error)
}
