//
//  NavigationRouter.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 08.05.2023.
//

import UIKit
import Combine

/// Навигационный переход к новому модулю
public final class NavigationModuleRouter<Assembly: ViewControllerAssembly, Presenter>: ToNavigationModuleRouting
where Assembly.Context: LifecycleManagingContextProtocol, Presenter: NavigationPresenter {
    public typealias Output = Assembly.Output
    public typealias Failure = Assembly.Failure
    public typealias Configuration = Assembly.Configuration
    
    public typealias ClosingContextFactory = (
        PassthroughSubject<Assembly.Output, Assembly.Failure>,
        PresentationContextProtocol,
        Bool
    ) -> ClosingContextProtocol
    
    public typealias PresenterFactory = (UIViewController) -> Presenter
    
    private let assembly: Assembly
    private let closingContextFactory: ClosingContextFactory
    private let presenterFactory: PresenterFactory
    
    /// Контекст, на котором выполняется презентация модуля
    private let presentationContext: PresentationContextProtocol
    
    public init(
        assembly: Assembly,
        presentationContext: PresentationContextProtocol,
        closingContextFactory: @escaping ClosingContextFactory,
        presenterFactory: @escaping PresenterFactory
    ) {
        self.assembly = assembly
        self.closingContextFactory = closingContextFactory
        self.presenterFactory = presenterFactory
        self.presentationContext = presentationContext
    }
    
    convenience init(
        assembly: Assembly,
        presentationContext: PresentationContextProtocol,
        presenterFactory: @escaping PresenterFactory
    ) {
        let closingContextFactory: ClosingContextFactory = { _, context, animated in
            NavigationClosingContext(
                presentationContext: context,
                animated: animated
            )
        }
        
        self.init(
            assembly: assembly,
            presentationContext: presentationContext,
            closingContextFactory: closingContextFactory,
            presenterFactory: presenterFactory
        )
    }
    
    /// Выполняет переход к модулю, который должен быть открыт на стеке навигации
    ///
    /// - Parameters:
    ///   - configuration: входные параметры модуля
    ///   - presentationConfiguration: настройки показа модуля
    ///   - shouldCompleteWithFirstValue: определяет, завершится ли продюсер при получении первого значения
    ///
    /// - Returns: продюсер, сообщающий о событиях в модуле
    public func route(
        configuration: Configuration,
        presentationConfiguration: NavigationPresentationConfiguration = .init(),
        shouldCompleteWithFirstValue: Bool = false
    ) -> AnyPublisher<Output, Failure> {
        Deferred { [assembly, presentationContext, closingContextFactory, presenterFactory] in
            let resultObserver = PassthroughSubject<Output, Failure>()
            
            let presentation = NavigationPresentation(
                assembly: assembly,
                resultObserver: resultObserver,
                config: configuration,
                context: presentationContext,
                presentationConfiguration: presentationConfiguration,
                closingContextFactory: closingContextFactory,
                presenterFactory: presenterFactory
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

public extension NavigationModuleRouter where Presenter == DefaultNavigationPresenter {
    convenience init(
        assembly: Assembly,
        presentationContext: PresentationContextProtocol
    ) {
        let presenterFactory: PresenterFactory = { viewController in
            DefaultNavigationPresenter(viewController: viewController)
        }
        
        let closingContextFactory: ClosingContextFactory = { _, context, animated in
            NavigationClosingContext(
                presentationContext: context,
                animated: animated
            )
        }
        
        self.init(
            assembly: assembly,
            presentationContext: presentationContext,
            closingContextFactory: closingContextFactory,
            presenterFactory: presenterFactory
        )
    }
    
    convenience init(
        assembly: Assembly,
        closingContextFactory: @escaping ClosingContextFactory,
        presentationContext: PresentationContextProtocol
    ) {
        let presenterFactory: PresenterFactory = { viewController in
            DefaultNavigationPresenter(viewController: viewController)
        }
        
        self.init(
            assembly: assembly,
            presentationContext: presentationContext,
            closingContextFactory: closingContextFactory,
            presenterFactory: presenterFactory
        )
    }
}
