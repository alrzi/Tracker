//
//  InterruptionClosingContext.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 04.10.2022.
//

import Foundation
import Combine

/// Контекст закрытия, посылающий `interrupt`, вместо закрытия модуля
///
/// - Note: Вариант использования: при закрытии экрана нужно завершить не текущий модуль,
/// а последовательность, описанную координатором, для этого можно использовать текущий контекст
/// и в координаторе, при получении соответствующего события из модуля,
/// завершить работу всей последовательности
public final class InterruptionClosingContext<Output, Failure: Error>: ClosingContextProtocol {
    private let observer: PassthroughSubject<Output, Failure>
    
    public init(observer: PassthroughSubject<Output, Failure>) {
        self.observer = observer
    }
    
    public func close(completion: (() -> Void)?) {
        observer.send(completion: .finished)
        completion?()
    }
}
