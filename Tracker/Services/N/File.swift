//
//  File.swift
//  Tracker
//
//  Created by Александр Зиновьев on 3/7/26.
//

import Foundation
import UserNotifications

// Типы расписания
enum ScheduleType: Codable {
    case once(Date)
    case daily(hour: Int, minute: Int)
    case weekly(days: [Weekday], hour: Int, minute: Int)

    func makeInstructions() -> [TriggerInstruction] {
        switch self {
        case .once(let date):
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            return [TriggerInstruction(slot: .once, components: comps, repeats: false)]

        case .daily(let hour, let minute):
            let comps = DateComponents(hour: hour, minute: minute)
            return [TriggerInstruction(slot: .daily, components: comps, repeats: true)]

        case .weekly(let days, let hour, let minute):
            return days.map { day in
                let comps = DateComponents(hour: hour, minute: minute, weekday: day.rawValue)
                return TriggerInstruction(slot: .weekly(day), components: comps, repeats: true)
            }
        }
    }
}

enum Weekday: Int, Sendable, CaseIterable, Codable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

    var all: [Self] { Self.allCases }
}

extension Array where Element == Weekday {
    static var all: [Self.Element] { Self.Element.allCases }
}

// Наша главная модель для хранения
struct NotificationRequest: Identifiable, Codable {
    let id: String
    let title: String
    let body: String?
    let schedule: ScheduleType
}

public enum NotificationAuthorizationStatus: Sendable {
    case notDetermined
    case denied
    case authorized
}

struct ScheduledEvent: Sendable {
    let descriptor: NotificationDescriptor
    let nextDate: Date
}

extension NotificationRequest {
    /// Превращает одну запись в базе в список конкретных событий с датами
    func generateScheduledEvents() -> [ScheduledEvent] {
        self.schedule.makeInstructions()
            .compactMap { inst in
                guard let nextDate = inst.nextTriggerDate else {
                    return nil
                }

                return ScheduledEvent(
                    descriptor: NotificationDescriptor(
                        id: inst.identifier(for: self.id),
                        title: self.title,
                        body: self.body ?? "",
                        components: inst.components,
                        repeats: inst.repeats
                    ),
                    nextDate: nextDate
                )
            }
    }
}

enum TriggerSlot: Sendable {
    case once
    case daily
    case weekly(Weekday)

    var suffix: String {
        switch self {
        case .once: return "_once"
        case .daily: return "_daily"
        case .weekly(let day): return "_w\(day.rawValue)"
        }
    }

    static var allPossibleSuffixes: [String] {
        let suffixes = [Self.once, .daily] + Weekday.allCases.map { .weekly($0) }
        return suffixes.map { $0.suffix }
    }
}

struct TriggerInstruction {
    let slot: TriggerSlot
    let components: DateComponents
    let repeats: Bool

    var nextTriggerDate: Date? {
        let calendar = Calendar.current
        let now = Date()

        // 1. Если это разовое уведомление (.once)
        // Нам нужно просто проверить, не прошла ли эта дата еще
        if !repeats {
            guard let date = calendar.date(from: components) else {
                return nil
            }
            
            return date > now ? date : nil
        }

        // 2. Если это повтор (daily, weekly)
        // Используем системный поиск следующего совпадения
        return calendar.nextDate(
            after: now,
            matching: components,
            matchingPolicy: .nextTime
        )
    }

    func identifier(for baseID: String) -> String {
        baseID + slot.suffix
    }
}

struct NotificationDescriptor: Sendable {
    let id: String
    let title: String
    let body: String
    let components: DateComponents
    let repeats: Bool
}

public enum NotificationError: Error, Sendable {
    case storageError(Error)
    case systemCenterError(Error)
    case providerError(id: String, error: Error) // Ошибка конкретного провайдера
    case authorizationDenied
    case taskCancelled
    case unknown(Error)
}

protocol NotificationProvider: Sendable {
    var providerID: String { get }

    func fetchRequests() async throws(NotificationError) -> [NotificationRequest]
}

protocol NotificationService: Sendable {
    /// Запланировать новое уведомление (сохранение + пуш)
    func schedule(_ request: NotificationRequest) async throws(NotificationError)

    /// Отменить уведомление по ID (удаление из базы + всех триггеров в iOS)
    func cancel(id: String) async throws(NotificationError)

    /// Синхронизировать базу с системой (лимит 64, восстановление после разрешений)
    func sync() async throws(NotificationError)
}

final class NotificationManager<Handler: NotificationActionHandler>: NotificationService {
    private let internalScheduler: InternalScheduler<Handler, ContinuousClock>
    private let storage: NotificationStorage
    private let center: NotificationCenterProtocol
    private let providers: [any NotificationProvider]
    private let maxSystemLimit = 64

    init(
        storage: NotificationStorage,
        center: NotificationCenterProtocol = UNUserNotificationCenter.current(),
        providers: [any NotificationProvider],
        actionHandler: Handler,
        clock: ContinuousClock = .continuous
    ) {
        self.storage = storage
        self.center = center
        self.providers = providers
        self.internalScheduler = InternalScheduler(storage: storage, handler: actionHandler, clock: clock)
    }

    // MARK: - API

    func schedule(_ request: NotificationRequest) async throws(NotificationError) {
        let isGranted = try await requestAuthorization()

        do {
            try await storage.save(request)
        } catch {
            throw .storageError(error)
        }

        if isGranted {
            let events = request.generateScheduledEvents()

            for event in events {
                do {
                    try await center.add(event.descriptor)
                } catch {
                    throw .systemCenterError(error)
                }
            }
        }
    }

    func cancel(id: String) async throws(NotificationError) {
        do {
            try await storage.remove(withID: id)
        } catch {
            throw .storageError(error)
        }

        let idsToRemove = TriggerSlot.allPossibleSuffixes.map { id + $0 }

        await center.removePendingNotificationRequests(withIdentifiers: idsToRemove)
        await center.removeDeliveredNotifications(withIdentifiers: idsToRemove)
    }

    // MARK: - Sync Engine

    func sync() async throws(NotificationError) {
        guard await center.currentAuthorizationStatus() == .authorized else {
            throw .authorizationDenied
        }

        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for provider in providers {
                    guard !Task.isCancelled else {
                        throw NotificationError.taskCancelled
                    }

                    group.addTask {
                        try await self.fetchAndSave(from: provider)
                    }
                }
                
                try await group.waitForAll()
            }
        } catch let error as NotificationError {
            throw error
        } catch {
            throw .unknown(error)
        }

        // 3. ФАЗА ПЛАНИРОВАНИЯ (Твой текущий код):
        // Теперь fetchAll() вернет уже обновленные провайдерами данные!
        let dbRequests = await storage.fetchAll()

        let allEventsSorted = dbRequests
            .flatMap { $0.generateScheduledEvents() }
            .sorted { $0.nextDate < $1.nextDate }

        let topItems = allEventsSorted.prefix(maxSystemLimit)
        let topIDs = Set(topItems.map { $0.descriptor.id })

        let currentSystemIDs = Set(await center.pendingNotificationIDs())
        let idsToRemove = currentSystemIDs.subtracting(topIDs)

        if !idsToRemove.isEmpty {
            await center.removePendingNotificationRequests(withIdentifiers: Array(idsToRemove))
        }

        for item in topItems {
            if !currentSystemIDs.contains(item.descriptor.id) {
                do {
                    try await center.add(item.descriptor)
                } catch {
                    throw .systemCenterError(error)
                }
            }
        }
    }

    // Вспомогательный метод для "распаковки" провайдера и сохранения в базу
    private func fetchAndSave<P: NotificationProvider>(from provider: P) async throws(NotificationError) {
        do {
            let requests = try await provider.fetchRequests()
            for request in requests {
                // Если ошибка случится здесь (в базе), она тоже уйдет в catch ниже
                try await storage.save(request)
            }
        } catch let error as NotificationError {
            // Если база уже кинула NotificationError, просто пробрасываем
            throw error
        } catch {
            // Оборачиваем любую другую ошибку (из сети или логики провайдера)
            throw .providerError(id: provider.providerID, error: error)
        }
    }
}

private extension NotificationManager {
    /// Запрос разрешений
    /// Возвращает true, если доступ получен (сейчас или был ранее)
    @discardableResult
    func requestAuthorization() async throws(NotificationError) -> Bool {
        let status = await center.currentAuthorizationStatus()

        switch status {
        case .notDetermined:
            // Показываем системный алерт (только 1 раз)
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            }
            catch {
                throw .authorizationDenied
            }

        case .denied:
            // Доступ закрыт, нужно слать в настройки (можно кинуть кастомную ошибку)
            return false

        case .authorized:
            return true

        @unknown default:
            return false
        }
    }
}

protocol NotificationCenterProtocol: Sendable {
    func currentAuthorizationStatus() async -> NotificationAuthorizationStatus
    func pendingNotificationIDs() async -> [String]

    // Передаем дескриптор вместо кучи параметров
    func add(_ descriptor: NotificationDescriptor) async throws

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) async
    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) async
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
}

extension UNUserNotificationCenter: NotificationCenterProtocol {
    func pendingNotificationIDs() async -> [String] {
        let requests = await self.pendingNotificationRequests()
        return requests.map { $0.identifier }
    }

    func add(_ descriptor: NotificationDescriptor) async throws {
        let content = UNMutableNotificationContent()
        content.title = descriptor.title
        content.body = descriptor.body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: descriptor.components,
            repeats: descriptor.repeats
        )

        let request = UNNotificationRequest(
            identifier: descriptor.id,
            content: content,
            trigger: trigger
        )

        try await self.add(request)
    }

    func currentAuthorizationStatus() async -> NotificationAuthorizationStatus {
        let settings = await self.notificationSettings()

        return switch settings.authorizationStatus {
        case .notDetermined: .notDetermined
        case .denied: .denied
        case .authorized, .provisional, .ephemeral: .authorized
        @unknown default: .denied
        }
    }
}

extension NotificationManager where Handler == EmptyNotificationActionHandler {
    convenience init(
        storage: some NotificationStorage,
        center: some NotificationCenterProtocol,
        providers: [any NotificationProvider]
    ) {
        self.init(
            storage: storage,
            center: center,
            providers: providers,
            actionHandler: EmptyNotificationActionHandler(),
            clock: .continuous
        )
    }
}

protocol NotificationStorage: Sendable {
    func save(_ request: NotificationRequest) async throws
    func remove(withID id: String) async throws
    func fetchAll() async -> [NotificationRequest]
}

protocol NotificationActionHandler: Sendable {
    /// Вызывается ровно в момент срабатывания таймера внутри приложения
    func onNotificationReceived(_ request: NotificationRequest) async
}

struct EmptyNotificationActionHandler: NotificationActionHandler {
    public init() {}
    public func onNotificationReceived(_ request: NotificationRequest) async {}
}

final actor InternalScheduler<Handler: NotificationActionHandler, C: Clock<Duration>>: Sendable {
    private let storage: NotificationStorage
    private let handler: Handler
    private let clock: C

    private var sleepTask: Task<(), Error>?

    public init(
        storage: NotificationStorage,
        handler: Handler,
        clock: C
    ) {
        self.storage = storage
        self.handler = handler
        self.clock = clock
    }

    /// Главный метод планирования. Ищет ближайшее событие и запускает таймер.
    public func scheduleNext() async {
        // 1. Отменяем старую задачу ожидания
        sleepTask?.cancel()

        // 2. Запрашиваем актуальные данные из базы
        let allRequests = await storage.fetchAll()

        // 3. Находим самое ближайшее событие, которое наступит в будущем
        let nextEvent = allRequests
            .flatMap { $0.generateScheduledEvents() }
            .filter { $0.nextDate > Date() }
            .min(by: { $0.nextDate < $1.nextDate })

        guard let event = nextEvent else {
            debugPrint("ℹ️ [InternalScheduler] Будущих событий не обнаружено.")
            return
        }

        let targetDate = event.nextDate
        let now = Date()
        let secondsToWait = targetDate.timeIntervalSince(now)

        sleepTask = Task {
            let duration = Duration.seconds(secondsToWait)
            debugPrint("⏳ [InternalScheduler] Спим \(secondsToWait) сек. до: \(event.descriptor.id)")

            do {
                // Спим в переданном нам Клоке (в тестах это будет мгновенно)
                try await self.clock.sleep(until: self.clock.now.advanced(by: duration), tolerance: nil)

                // Проверяем, не отменили ли нас за время сна (например, вызван cancel())
                guard !Task.isCancelled else {
                    return
                }

                // 5. Извлекаем чистый ID без суффиксов
                let baseID = self.extractBaseID(from: event.descriptor.id)

                // 6. Находим оригинальный запрос, чтобы отдать его пользователю в Handler
                if let originalRequest = allRequests.first(where: { $0.id == baseID }) {
                    await self.handler.onNotificationReceived(originalRequest)
                }

                // 7. После того как событие "прозвучало", ищем следующее
                await self.scheduleNext()

            } catch {
                // Сюда попадаем, если Task.sleep был прерван вызовом .cancel()
                debugPrint("ℹ️ [InternalScheduler] Таймер сброшен или остановлен.")
            }
        }
    }

    /// Останавливает планировщик полностью
    public func stop() async {
        sleepTask?.cancel()
        sleepTask = nil
    }

    // MARK: - Private Helpers

    /// Убирает все наши технические суффиксы (_once, _daily, _w1...),
    /// чтобы вернуть пользователю чистый ID, который он создавал.
    private func extractBaseID(from systemID: String) -> String {
        var rawValue = systemID
        for suffix in TriggerSlot.allPossibleSuffixes {
            rawValue = rawValue.replacingOccurrences(of: suffix, with: "")
        }
        return rawValue
    }
}

actor Storage: NotificationStorage {
    // Временное хранилище в памяти
    private var requests: [String: NotificationRequest] = [:]

    func save(_ request: NotificationRequest) throws {
        print("💾 Storage: Сохранение \(request.id)")
        requests[request.id] = request
    }

    func remove(withID id: String) throws {
        print("🗑️ Storage: Удаление \(id)")
        requests.removeValue(forKey: id)
    }

    func fetchAll() -> [NotificationRequest] {
        print("📂 Storage: Чтение всех записей (всего: \(requests.count))")
        // Возвращаем массив, отсортированный по ID для стабильности
        return Array(requests.values).sorted { $0.id < $1.id }
    }
}

actor MockNotificationCenter: NotificationCenterProtocol {
    // Теперь храним дескрипторы (наш Sendable тип) вместо системных запросов
    private var pendingDescriptors: [String: NotificationDescriptor] = [:]

    // Позволяет имитировать разные статусы разрешений в тестах
    var stubbedStatus: NotificationAuthorizationStatus = .authorized

    func currentAuthorizationStatus() async -> NotificationAuthorizationStatus {
        return stubbedStatus
    }

    func pendingNotificationIDs() async -> [String] {
        return Array(pendingDescriptors.keys)
    }

    func add(_ descriptor: NotificationDescriptor) async throws {
        print("🛠️ MockCenter: Запланировано \(descriptor.id)")
        // В iOS добавление с тем же ID перезаписывает старое уведомление
        pendingDescriptors[descriptor.id] = descriptor
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        print("🛠️ MockCenter: Удаление \(identifiers)")
        for id in identifiers {
            pendingDescriptors.removeValue(forKey: id)
        }
    }

    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        // В моке для тестов планирования обычно ничего не делаем
    }

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        return stubbedStatus == .authorized
    }
}

extension MockNotificationCenter {
    func setStubbedStatus(_ status: NotificationAuthorizationStatus) {
        self.stubbedStatus = status
    }
}

final actor SpyHandler: NotificationActionHandler {
    // Используем потокобезопасный счетчик или просто проверяем результат в тестах
    private var count = 0
    // Если нет библиотек атомарности, можно использовать lock

    var callCount: Int { count }

    func onNotificationReceived(_ request: NotificationRequest) async {
        count += 1
        print("🔔 SpyHandler: Получено \(request.title)")
    }
}

extension Task where Success == Never, Failure == Never {
    static func megaYield() async {
        for _ in 1...20 {
            await Task<Void, Never>.detached(priority: .background) {
                await Task<Never, Never>.yield()
            }.value
        }
    }
}

extension NSLock {
    @inlinable
    @discardableResult
    func sync<R>(operation: () -> R) -> R {
        self.lock()
        defer { self.unlock() }
        return operation()
    }
}

extension NSRecursiveLock {
    @inlinable
    @discardableResult
    func sync<R>(operation: () -> R) -> R {
        self.lock()
        defer { self.unlock() }
        return operation()
    }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
public final class TestClock<Duration: DurationProtocol & Hashable>: Clock, @unchecked Sendable {
    public struct Instant: InstantProtocol {
        fileprivate let offset: Duration

        public init(offset: Duration = .zero) {
            self.offset = offset
        }

        public func advanced(by duration: Duration) -> Self {
            .init(offset: self.offset + duration)
        }

        public func duration(to other: Self) -> Duration {
            other.offset - self.offset
        }

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.offset < rhs.offset
        }
    }

    public var minimumResolution: Duration = .zero
    public private(set) var now: Instant

    private let lock = NSRecursiveLock()
    private var suspensions:
    [(
        id: UUID,
        deadline: Instant,
        continuation: AsyncThrowingStream<Never, Error>.Continuation
    )] = []

    public init(now: Instant = .init()) {
        self.now = now
    }

    public func sleep(until deadline: Instant, tolerance: Duration? = nil) async throws {
        try Task.checkCancellation()
        let id = UUID()
        do {
            let stream: AsyncThrowingStream<Never, Error>? = self.lock.sync {
                guard deadline >= self.now
                else {
                    return nil
                }
                return AsyncThrowingStream<Never, Error> { continuation in
                    self.suspensions.append((id: id, deadline: deadline, continuation: continuation))
                }
            }
            guard let stream = stream
            else { return }
            for try await _ in stream {}
            try Task.checkCancellation()
        } catch is CancellationError {
            self.lock.sync { self.suspensions.removeAll(where: { $0.id == id }) }
            throw CancellationError()
        } catch {
            throw error
        }
    }

    /// Throws an error if there are active sleeps on the clock.
    ///
    /// This can be useful for proving that your feature will not perform any more time-based
    /// asynchrony. For example, the following will throw because the clock has an active suspension
    /// scheduled:
    ///
    /// ```swift
    /// let clock = TestClock()
    /// Task {
    ///   try await clock.sleep(for: .seconds(1))
    /// }
    /// try await clock.checkSuspension()
    /// ```
    ///
    /// However, the following will not throw because advancing the clock has finished the suspension:
    ///
    /// ```swift
    /// let clock = TestClock()
    /// Task {
    ///   try await clock.sleep(for: .seconds(1))
    /// }
    /// await clock.advance(for: .seconds(1))
    /// try await clock.checkSuspension()
    /// ```
    public func checkSuspension() async throws {
        await Task.megaYield()
        guard self.lock.sync(operation: { self.suspensions.isEmpty })
        else { throw SuspensionError() }
    }

    /// Advances the test clock's internal time by the duration.
    ///
    /// See the documentation for ``TestClock`` to see how to use this method.
    public func advance(by duration: Duration = .zero) async {
        await self.advance(to: self.lock.sync(operation: { self.now.advanced(by: duration) }))
    }

    /// Advances the test clock's internal time to the deadline.
    ///
    /// See the documentation for ``TestClock`` to see how to use this method.
    public func advance(to deadline: Instant) async {
        while self.lock.sync(operation: { self.now <= deadline }) {
            await Task.megaYield()
            let `return` = {
                self.lock.lock()
                self.suspensions.sort { $0.deadline < $1.deadline }

                guard
                    let next = self.suspensions.first,
                    deadline >= next.deadline
                else {
                    self.now = deadline
                    self.lock.unlock()
                    return true
                }

                self.now = next.deadline
                self.suspensions.removeFirst()
                self.lock.unlock()
                next.continuation.finish()
                return false
            }()

            if `return` {
                await Task.megaYield()
                return
            }
        }
        await Task.megaYield()
    }

    /// Runs the clock until it has no scheduled sleeps left.
    ///
    /// This method is useful for letting a clock run to its end without having to explicitly account
    /// for each sleep. For example, suppose you have a feature that runs a timer for 10 ticks, and
    /// each tick it increments a counter. If you don't want to worry about advancing the timer for
    /// each tick, you can instead just `run` the clock out:
    ///
    /// ```swift
    /// func testTimer() async {
    ///   let clock = TestClock()
    ///   let model = FeatureModel(clock: clock)
    ///
    ///   XCTAssertEqual(model.count, 0)
    ///   model.startTimerButtonTapped()
    ///
    ///   await clock.run()
    ///   XCTAssertEqual(model.count, 10)
    /// }
    /// ```
    ///
    /// It is possible to run a clock that never finishes, hence causing a suspension that never
    /// finishes. This can happen if you create an unbounded timer. In order to prevent holding up
    /// your test suite forever, the ``run(timeout:file:line:)`` method will terminate and cause a
    /// test failure if a timeout duration is reached.
    ///
    /// - Parameters:
    ///   - duration: The amount of time to allow for all work on the clock to finish.
    public func run(
        timeout duration: Swift.Duration = .milliseconds(500),
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) async {
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    try await Task.sleep(until: .now.advanced(by: duration), clock: .continuous)
                    for suspension in self.suspensions {
                        suspension.continuation.finish(throwing: CancellationError())
                    }
                    throw CancellationError()
                }
                group.addTask {
                    await Task.megaYield()
                    while let deadline = self.lock.sync(operation: { self.suspensions.first?.deadline }) {
                        try Task.checkCancellation()
                        await self.advance(by: self.lock.sync(operation: { self.now.duration(to: deadline) }))
                    }
                }
                try await group.next()
                group.cancelAll()
            }
        } catch {

        }
    }
}

/// An error that indicates there are actively suspending sleeps scheduled on the clock.
///
/// This error is thrown automatically by ``TestClock/checkSuspension()`` if there are actively
/// suspending sleeps scheduled on the clock.
public struct SuspensionError: Error {}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
extension TestClock where Duration == Swift.Duration {
    public convenience init() {
        self.init(now: .init())
    }
}
