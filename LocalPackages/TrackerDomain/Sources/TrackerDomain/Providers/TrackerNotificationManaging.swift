//
//  TrackerNotificationManaging.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 3/19/26.
//

import Foundation

public protocol TrackerNotificationManaging: Sendable {
    /// Получить текущие настройки уведомлений для трекера
    func fetchInformation(for trackerId: UUID) async throws -> TrackerNotificationInformation

    /// Сохранить/обновить расписание для конкретного трекера
    /// - days: словарь, где ключ — день недели, а значение — время уведомления
    func saveSchedule(for trackerId: UUID, schedule: [WeekDay: Date]) async throws

    /// Удалить все уведомления для конкретного трекера
    func removeAllNotifications(for trackerId: UUID) async throws
}
