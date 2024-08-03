//
//  ModalModuleRouter.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 08.05.2023.
//

import Foundation
import Combine
import Combine

/// Модальный переход к новому модулю
public final class ModalModuleRouter<Assembly: ViewControllerAssembly>: ToModalModuleRouting
where Assembly.Context: LifecycleManagingContextProtocol {
    public typealias Output = Assembly.Output
    public typealias Failure = Assembly.Failure
    public typealias Configuration = Assembly.Configuration
    
    public typealias ClosingContextFactory = (
        PassthroughSubject<Assembly.Output, Assembly.Failure>,
        PresentationContextProtocol,
        Bool
    ) -> ClosingContextProtocol
    
    private let assembly: Assembly
    private let closingContextFactory: ClosingContextFactory
    
    /// Контекст, на котором выполняется презентация модуля
    private let presentationContext: PresentationContextProtocol
    
    private var cancellable: Cancellable?
    
    public init(
        assembly: Assembly,
        presentationContext: PresentationContextProtocol,
        closingContextFactory: @escaping ClosingContextFactory
    ) {
        self.assembly = assembly
        self.presentationContext = presentationContext
        self.closingContextFactory = closingContextFactory
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
        presentationConfiguration: ModalPresentationConfiguration = .init(),
        shouldCompleteWithFirstValue: Bool = true
    ) -> AnyPublisher<Output, Failure> {
        Deferred { [assembly, presentationContext, closingContextFactory] in
            let resultObserver = PassthroughSubject<Output, Failure>()
            
            let presentation = ModalPresentation(
                assembly: assembly,
                resultObserver: resultObserver,
                config: configuration,
                context: presentationContext,
                presentationConfiguration: presentationConfiguration,
                closingContextFactory: closingContextFactory
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

public extension ModalModuleRouter {
    convenience init(
        assembly: Assembly,
        presentationContext: PresentationContextProtocol
    ) {
        let closingContextFactory: ClosingContextFactory = { _, context, animated in
            ModalClosingContext(
                presentationContext: context,
                animated: animated
            )
        }
        
        self.init(
            assembly: assembly,
            presentationContext: presentationContext,
            closingContextFactory: closingContextFactory
        )
    }
}
