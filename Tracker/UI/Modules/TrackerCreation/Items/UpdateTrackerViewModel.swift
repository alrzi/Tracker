//
//  UpdateTrackerViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 29.07.2024.
//

import Foundation

struct UpdateTrackerViewModel {
    let name: String
    let emoji: IndexPath
    let color: IndexPath
}

struct UpdateTrackedDaysViewModel {
    let trackedDays: String
    let isTrackedForToday: Bool
}
