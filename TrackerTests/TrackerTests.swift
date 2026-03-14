//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Александр Зиновьев on 3/7/26.
//

import Testing
@testable import Tracker
import Foundation

struct TrackerTests {
    // Вспомогательный метод для генерации пачки уведомлений
    func makeRequests(count: Int) -> [NotificationRequest] {
        (1...count).map { i in
            NotificationRequest(
                id: "id_\(i)",
                title: "Title \(i)",
                body: "Body \(i)",
                schedule: .daily(hour: (i % 24), minute: 0)
            )
        }
    }

    @Test
    func `weeklyNotificationsCreation`() async throws {
        let storage = Storage()
        let mockCenter = MockNotificationCenter()
        let manager = NotificationManager(storage: storage, center: mockCenter, providers: [])

        try await manager.schedule(
            NotificationRequest(
                id: "weight",
                title: "hello it s time to measure weight!",
                body: nil,
                schedule: .weekly(days: .all, hour: 9, minute: 14)
            )
        )        
    }

    @Test("Проверка лимита в 64 уведомления")
    func testMaxLimit() async throws {
        // Given: База с 100 уведомлениями и пустой MockCenter
        let storage = Storage() // Наша заглушка-актор
        let mockCenter = MockNotificationCenter()
        let manager = NotificationManager(storage: storage, center: mockCenter, providers: [])

        let requests = makeRequests(count: 100)
        for r in requests { try await storage.save(r) }

        // When: Запускаем синхронизацию
        try await manager.sync()

        // Then: В системе должно быть ровно 64 ID
        let pendingIDs = await mockCenter.pendingNotificationIDs()
        #expect(pendingIDs.count == 64)
    }

    @Test("Проверка приоритизации ближайших уведомлений")
    func testPriority() async throws {
        let storage = Storage()
        let mockCenter = MockNotificationCenter()
        let manager = NotificationManager(storage: storage, center: mockCenter, providers: [])

        // Одно уведомление через час, другое через 23 часа
        let soon = NotificationRequest(id: "soon", title: "Soon", body: nil,
                                       schedule: .once(Date().addingTimeInterval(3600)))
        let later = NotificationRequest(id: "later", title: "Later", body: nil,
                                        schedule: .once(Date().addingTimeInterval(82800)))

        try await storage.save(soon)
        try await storage.save(later)

        // Ограничим лимит до 1 для теста (нужно будет сделать maxSystemLimit подменяемым или просто проверить порядок)
        try await manager.sync()

        let pendingIDs = await mockCenter.pendingNotificationIDs()
        #expect(pendingIDs.contains("soon_once"))
    }

    @Test("Удаление уведомления и всех его производных ID")
    func testCancelation() async throws {
        let storage = Storage()
        let mockCenter = MockNotificationCenter()
        let manager = NotificationManager(storage: storage, center: mockCenter, providers: [])

        // Создаем еженедельное (оно породит несколько ID)
        let weekly = NotificationRequest(id: "gym", title: "Gym", body: nil,
                                         schedule: .weekly(days: [.tuesday, .thursday, .saturday], hour: 10, minute: 0))

        try await manager.schedule(weekly)

        // Проверяем, что в системе появились хвосты (например, gym_2, gym_4...)
        let initialIDs = await mockCenter.pendingNotificationIDs()
        #expect(initialIDs.count == 3)

        // When: Удаляем корень
        try await manager.cancel(id: "gym")

        // Then: База и система должны быть пусты
        let finalDB = await storage.fetchAll()
        let finalSystem = await mockCenter.pendingNotificationIDs()

        #expect(finalDB.isEmpty)
        #expect(finalSystem.isEmpty)
    }

    @Test("Планирование цепочки уведомлений на 7 дней вперед")
    func testSevenDaysChallenge() async throws {
        // Given: Настройка окружения
        let storage = Storage() // Наш актер-заглушка
        let mockCenter = MockNotificationCenter()
        let manager = NotificationManager(storage: storage, center: mockCenter, providers: [])

        let calendar = Calendar.current
        let today = Date()

        // 1. Генерируем 7 уведомлений (по одному на каждый следующий день)
        for dayOffset in 1...7 {
            // Вычисляем дату: сегодня + X дней
            guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: today),
                  let scheduledDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: targetDate) else {
                continue
            }

            let request = NotificationRequest(
                id: "challenge_day_\(dayOffset)", // Уникальный ID для каждого дня
                title: "День \(dayOffset)",
                body: "Твое ежедневное задание уже ждет!",
                schedule: .once(scheduledDate) // Используем .once, так как это конкретные даты
            )

            // 2. Планируем через менеджер
            try await manager.schedule(request)
        }

        // Then: Проверяем результаты

        // В базе должно быть 7 записей
        let dbCount = await storage.fetchAll().count
        #expect(dbCount == 7)

        // В системе (MockCenter) должно быть 7 ID с суффиксом _once
        let systemIDs = await mockCenter.pendingNotificationIDs()
        #expect(systemIDs.count == 7)

        // Проверим наличие конкретного ID, например для 5-го дня
        #expect(systemIDs.contains("challenge_day_5_once"))

        print("✅ Успешно запланировано 7 дней: \(systemIDs.sorted())")
    }

    @Test("Восстановление уведомлений при появлении разрешений")
    func testSyncRestoration() async throws {
        let storage = Storage()
        let mockCenter = MockNotificationCenter()
        let manager = NotificationManager(storage: storage, center: mockCenter, providers: [])

        // 1. Имитируем отказ в доступе
        await mockCenter.setStubbedStatus(.denied)
        let request = NotificationRequest(id: "test", title: "Test", body: nil, schedule: .daily(hour: 10, minute: 0))

        try await manager.schedule(request)

        // В системе пусто, но в базе есть
        let systemBefore = await mockCenter.pendingNotificationIDs()
        #expect(systemBefore.isEmpty)

        // 2. Юзер разрешил, запускаем sync
        await mockCenter.setStubbedStatus(.authorized)
        try await manager.sync()

        // В системе должно появиться уведомление
        let systemAfter = await mockCenter.pendingNotificationIDs()
        #expect(systemAfter.contains("test_daily"))
    }

    @Test("Проверка срабатывания внутреннего планировщика")
    func testInternalScheduler() async throws {
        // 1. Инициализация
        let clock = TestClock()
        let handler = SpyHandler()
        let storage = Storage() // Наш актер-заглушка
        let scheduler = InternalScheduler(storage: storage, handler: handler, clock: clock)

        // 2. ДОБАВЛЯЕМ ДАННЫЕ: Уведомление через 1 час (3600 секунд)
        let fireDate = Date().addingTimeInterval(3654)
        let request = NotificationRequest(
            id: "test_event",
            title: "Пора вставать",
            body: "Тестовое событие",
            schedule: .once(fireDate)
        )

        try await storage.save(request)

        await scheduler.scheduleNext()

        await clock.advance(by: .seconds(3600))

        #expect(await handler.callCount == 1)
    }
}
