//
//  PopoverModuleRouter.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 18.05.2023.
//

import Foundation
import Combine

/// Модальный переход к новому модулю
public final class PopoverModuleRouter<Assembly: ViewControllerAssembly>: ToPopoverModuleRouting
where Assembly.Context: LifecycleManagingContextProtocol {
    public typealias Output = Assembly.Output
    public typealias Failure = Assembly.Failure
    public typealias Configuration = Assembly.Configuration
    
    private let assembly: Assembly
    
    /// Контекст, на котором выполняется презентация модуля
    private let presentationContext: PresentationContextProtocol
    
    public init(assembly: Assembly, presentationContext: PresentationContextProtocol) {
        self.assembly = assembly
        self.presentationContext = presentationContext
    }
    
    /// Выполняет переход к модулю, который должен быть открыт модально
    ///
    /// - Parameters:
    ///   - configuration: входные параметры модуля
    ///   - presentationConfiguration: настройки показа модуля
    ///   - shouldCompleteWithFirstValue: определяет, завершится ли продюсер при получении первого значения
    ///
    /// - Returns: продюсер, сообщающий о событиях в модуле
    public func route(
        configuration: Configuration,
        presentationConfiguration: PopoverPresentationConfiguration,
        shouldCompleteWithFirstValue: Bool = true
    ) -> AnyPublisher<Output, Failure> {
        Deferred { [assembly, presentationContext] in
            let resultObserver = PassthroughSubject<Output, Failure>()
            
            let presentation = PopoverPresentation(
                assembly: assembly,
                resultObserver: resultObserver,
                configuration: configuration,
                presentationContext: presentationContext,
                presentationConfiguration: presentationConfiguration
            )
            
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
