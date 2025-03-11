//
//  ObservableActor+readOnly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation

extension ObservableActor {
    /// Создаёт обертку, оставляющую только функциональность `AsyncSequence`, без возможности изменить значение
    public nonisolated func readOnly() -> ReadOnlyObservableWrapper<Value> {
        .init(self)
    }
}

/// Обёртка над ``ObservableActor``, позволяющая только наблюдать за изменениями значений, но не изменять их
///
/// Нужен для использования в качестве конкретного типа, пока мы не можем указать тип элемента у `some AsyncSequence`.
public struct ReadOnlyObservableWrapper<Value: Sendable>: Sendable {
    private let observableActor: ObservableActor<Value>
    
    public init(_ observableActor: ObservableActor<Value>) {
        self.observableActor = observableActor
    }
}

extension ReadOnlyObservableWrapper: AsyncSequence {
    public func makeAsyncIterator() -> ObservableActor<Value>.AsyncIterator {
        observableActor.makeAsyncIterator()
    }
}
