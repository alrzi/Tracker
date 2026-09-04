//
//  TrackerFormHabitScheduleViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 3/14/26.
//

import Foundation
import Notifications
import TrackerDomain
import UIKit

@MainActor
final class TrackerFormHabitScheduleViewModel: ObservableObject {
    private let permissionManager: any PermissionManagerProtocol

    @Published var configs: [TrackerHabitDayConfig] = []
    @Published var showPermissionAlert = false

    init(
        permissionManager: some PermissionManagerProtocol = PermissionManager(),
        selectedDays: Set<WeekDay>,
        info: TrackerNotificationInformation?
    ) {
        self.permissionManager = permissionManager

        self.configs = WeekDay.allSortedBySystem.map {
            .init(day: $0, isSelected: selectedDays.contains($0), details: info?.schedule[$0])
        }
    }

    func toggleDay(_ day: WeekDay) {
        guard let index = configs.firstIndex(where: { $0.day == day }) else { return }
        configs[index].toggleSelection()
    }

    func toggleNotification(for day: WeekDay) {
        guard let index = configs.firstIndex(where: { $0.day == day }) else { return }

        if !configs[index].notification.isEnabled {
            Task {
                let granted = (try? await permissionManager.requestNotificationAuthorization()) ?? false
                if granted {
                    configs[index].setNotification(enabled: true)
                } else {
                    showPermissionAlert = true
                }
            }
        } else {
            configs[index].setNotification(enabled: false)
        }
    }

    func update(_ day: WeekDay, with newTime: Date) {
        guard let index = configs.firstIndex(where: { $0.day == day }) else { return }
        configs[index].updateTime(newTime)
    }

    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
