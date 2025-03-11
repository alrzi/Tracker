//
//  ObservableActor.swift
//  Tracker
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation

/// Актор, предоставляющий историю своих изменений в виде асинхронной последовательности
public actor ObservableActor<Value: Sendable>: Sendable {
    public private(set) var value: Value {
        didSet { observations.notifyAll(value: value) }
    }
    
    private var observations = Observations()
    
    public init(_ value: Value) {
        self.value = value
    }
    
    /// Устанавливает новое значение
    /// - Parameter value: Новое значение для установки
    ///
    /// - Note: Состояние будет обновлено даже если новое значение совпадает со старым. Если требуется поменять значение только
    /// когда оно отличается от текущего, следует использовать ``setIfNeeded(value:)``
    public func set(value: Value) {
        self.value = value
    }
    
    /// Устанавливает новое значение, вычисляя его на основе текущего
    /// - Parameter transform: Преобразование, получающее новое значение из текущего
    ///
    /// - Note: Состояние будет обновлено даже если новое значение совпадает со старым. Если требуется поменять значение только
    /// когда оно отличается от текущего, следует использовать ``transformValueIfNeeded(_:)``
    public func transformValue(_ transform: (Value) -> Value) {
        set(value: transform(value))
    }
    
    /// Выполняет некоторые действия на основе текущего значения
    /// - Parameter actions: Действия для выполнения
    public func perform(actions: (Value) -> Void) {
        actions(value)
    }
}

extension ObservableActor where Value: Equatable {
    /// Устанавливает новое значение
    ///
    /// - Parameter value: Новое значение для установки
    ///
    /// В отличие от ``set(value:)``, данный метод изменит состояние только если новое значение отличается от текущего.
    public func setIfNeeded(value: Value) {
        guard self.value != value else {
            return
        }
        
        set(value: value)
    }
    
    /// Устанавливает новое значение, вычисляя его на основе текущего
    /// - Parameter transform: Преобразование, получающее новое значение из текущего
    ///
    /// В отличие от ``transformValue(_:)``, данный метод изменит состояние только если новое значение отличается от текущего.
    public func transformValueIfNeeded(_ transform: (Value) -> Value) {
        setIfNeeded(value: transform(value))
    }
}

extension ObservableActor: AsyncSequence {
    public nonisolated func makeAsyncIterator() -> AsyncStream<Value>.Iterator {
        AsyncStream<Value> { [weak self] continuation in
            Task { @Sendable [weak self] () in
                guard let self else {
                    continuation.finish()
                    return
                }
                
                await self.register(continuation: continuation)
            }
        }
        .makeAsyncIterator()
    }
}

private extension ObservableActor {
    func register(continuation: AsyncStream<Value>.Continuation) {
        let subscription = observations.register(continuation: continuation)
        
        let id = subscription.id
        
        continuation.onTermination = { @Sendable [weak self] _ in
            Task {
                await self?.remove(subscriptionId: id)
            }
        }
        
        continuation.yield(value)
    }
    
    func remove(subscriptionId: Observations.Subscription.ID) {
        observations.remove(subscriptionId: subscriptionId)
    }
    
    struct Observations {
        private var subscriptions: [Subscription.ID: Subscription] = [:]
        
        func notifyAll(value: Value) {
            for subscription in subscriptions.values {
                subscription.continuation.yield(value)
            }
        }
        
        mutating func register(continuation: AsyncStream<Value>.Continuation) -> Subscription {
            let subscription = Subscription(id: UUID(), continuation: continuation)
            
            subscriptions[subscription.id] = subscription
            
            return subscription
        }
        
        mutating func remove(subscriptionId: Subscription.ID) {
            subscriptions.removeValue(forKey: subscriptionId)
        }
        
        struct Subscription: Identifiable {
            let id: UUID
            let continuation: AsyncStream<Value>.Continuation
        }
    }
}
