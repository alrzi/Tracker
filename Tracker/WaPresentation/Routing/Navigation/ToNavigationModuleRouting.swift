//
//  ToNavigationModuleRouting.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 08.05.2023.
//

import Foundation
import Combine

public protocol ToNavigationModuleRouting: ToModuleRouting
where PresentationConfiguration == NavigationPresentationConfiguration { }

public extension ToNavigationModuleRouting {
    /// Выполняет переход к модулю, который должен быть открыт на стеке навигации
    ///
    /// - Parameters:
    ///   - configuration: входные параметры модуля
    ///   - presentationConfiguration: настройки показа модуля
    ///
    /// - Returns: продюсер, сообщающий о событиях в модуле
    func route(
        configuration: Configuration,
        presentationConfiguration: NavigationPresentationConfiguration = .init()
    ) -> AnyPublisher<Output, Failure> {
        return route(
            configuration: configuration,
            presentationConfiguration: presentationConfiguration,
            shouldCompleteWithFirstValue: false
        )
    }
}

public extension ToNavigationModuleRouting where Configuration == () {
    /// Выполняет переход к модулю, который должен быть открыт на стеке навигации
    ///
    /// - Parameters:
    ///   - presentationConfiguration: настройки показа модуля
    ///   - shouldCompleteWithFirstValue: определяет, завершится ли продюсер при получении первого значения
    ///
    /// - Returns: продюсер, сообщающий о событиях в модуле
    func route(
        presentationConfiguration: NavigationPresentationConfiguration = .init(),
        shouldCompleteWithFirstValue: Bool = false
    ) -> AnyPublisher<Output, Failure> {
        return route(
            configuration: (),
            presentationConfiguration: presentationConfiguration,
            shouldCompleteWithFirstValue: shouldCompleteWithFirstValue
        )
    }
}
