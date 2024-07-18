//
//  ToPopoverModuleRouting.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 18.05.2023.
//

import Foundation
import Combine

public protocol ToPopoverModuleRouting: ToModuleRouting
where PresentationConfiguration == PopoverPresentationConfiguration { }

public extension ToPopoverModuleRouting where Configuration == () {
    /// Выполняет переход к модулю, который должен быть открыт модально
    ///
    /// - Parameters:
    ///   - presentationConfiguration: настройки показа модуля
    ///   - shouldCompleteWithFirstValue: определяет, завершится ли продюсер при получении первого значения
    ///
    /// - Returns: продюсер, сообщающий о событиях в модуле
    func route(
        presentationConfiguration: PopoverPresentationConfiguration,
        shouldCompleteWithFirstValue: Bool = true
    ) -> AnyPublisher<Output, Failure> {
        return route(
            configuration: (),
            presentationConfiguration: presentationConfiguration,
            shouldCompleteWithFirstValue: shouldCompleteWithFirstValue
        )
    }
}
