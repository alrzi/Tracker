//
//  LifecycleManagingContextProtocol.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 10.05.2023.
//

import Foundation
import Combine

/// Контекст сборки модуля, позволяющий следить за жизненным циклом модуля и управлять им.
public protocol LifecycleManagingContextProtocol<Output, Failure, Configuration> {
    /// Результат работы модуля
    associatedtype Output
    
    /// Ошибка при работе модуля
    associatedtype Failure: Error
    
    /// Входные параметры модуля
    associatedtype Configuration
    
    /// Наблюдатель, позволяющий посылать события из модуля наружу
    var resultObserver: PassthroughSubject<Output, Failure> { get }
    
    /// Контекст, позволяющий закрыть модуль
    var closingContext: ClosingContextProtocol { get }
    
    /// Входные параметры модуля
    var configuration: Configuration { get }
    
    /// Инициализация контекста
    ///
    /// - Parameters:
    ///   - resultObserver: наблюдатель, позволяющий посылать события из модуля наружу
    ///   - closingContext: контекст, позволяющий закрыть модуль
    ///   - configuration: входные параметры модуля
    init(
        resultObserver: PassthroughSubject<Output, Failure>,
        closingContext: ClosingContextProtocol,
        configuration: Configuration
    )
}
