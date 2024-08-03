//
//  ToModalModuleRouting.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 08.05.2023.
//

import Foundation
import Combine

public protocol ToModalModuleRouting: ToModuleRouting
where PresentationConfiguration == ModalPresentationConfiguration { }

public extension ToModalModuleRouting {
    /// Выполняет переход к модулю, который должен быть открыт модально
    ///
    /// - Parameters:
    ///   - configuration: входные параметры модуля
    ///   - presentationConfiguration: настройки показа модуля
    ///
    /// - Returns: продюсер, сообщающий о событиях в модуле
    func route(
        configuration: Configuration,
        presentationConfiguration: ModalPresentationConfiguration = .init()
    ) -> AnyPublisher<Output, Failure> {
        return route(
            configuration: configuration,
            presentationConfiguration: presentationConfiguration,
            shouldCompleteWithFirstValue: true
        )
    }
}

public extension ToModalModuleRouting where Configuration == () {
    /// Выполняет переход к модулю, который должен быть открыт модально
    ///
    /// - Parameters:
    ///   - presentationConfiguration: настройки показа модуля
    ///   - shouldCompleteWithFirstValue: определяет, завершится ли продюсер при получении первого значения
    ///
    /// - Returns: продюсер, сообщающий о событиях в модуле
    func route(
        presentationConfiguration: ModalPresentationConfiguration = .init(),
        shouldCompleteWithFirstValue: Bool = true
    ) -> AnyPublisher<Output, Failure> {
        route(
            configuration: (),
            presentationConfiguration: presentationConfiguration,
            shouldCompleteWithFirstValue: shouldCompleteWithFirstValue
        )
    }
}
