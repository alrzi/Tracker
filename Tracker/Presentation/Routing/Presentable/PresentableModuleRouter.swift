//
//  PresentableModuleRouter.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 08.06.2023.
//

import Foundation
import Combine

/// Любой переход к новому модулю
public final class PresentableModuleRouter<Output, Failure, Configuration, PresentationConfiguration>: ToModuleRouting
where Failure: Error {
    public typealias PresentationFactory = (
        PassthroughSubject<Output, Failure>,
        Configuration,
        PresentationConfiguration
    ) -> Presentable
    
    private let factory: PresentationFactory
    
    public init(factory: @escaping PresentationFactory) {
        self.factory = factory
    }
    
    /// Выполняет переход к модулю, который должен быть открыт
    ///
    /// - Parameters:
    ///   - configuration: входные параметры модуля
    ///   - presentationConfiguration: настройки показа модуля
    ///   - shouldCompleteWithFirstValue: определяет, завершится ли продюсер при получении первого значения
    ///
    /// - Returns: продюсер, сообщающий о событиях в модуле
    public func route(
        configuration: Configuration,
        presentationConfiguration: PresentationConfiguration,
        shouldCompleteWithFirstValue: Bool
    ) -> AnyPublisher<Output, Failure> {
        Deferred { [factory] in
            let resultObserver = PassthroughSubject<Output, Failure>()
            
            let presentation = factory(resultObserver, configuration, presentationConfiguration)
            
            presentation.present()
            
            return resultObserver
        }
        .prefix(shouldCompleteWithFirstValue ? 1 : .max)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    deinit {
        print(String(describing: self) + "Deinit")
    }
}
