//
//  NavigationPresentation.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 30.08.2022.
//

import UIKit
import Combine

public final class NavigationPresentation<Assembly: ViewControllerAssembly, Presenter: NavigationPresenter>: Presentable
where Assembly.Context: LifecycleManagingContextProtocol {
    public typealias Output = Assembly.Context.Output
    public typealias Failure = Assembly.Context.Failure
    public typealias Configuration = Assembly.Context.Configuration
    
    public typealias ClosingContextFactory = (
        PassthroughSubject<Output, Failure>,
        PresentationContextProtocol,
        Bool
    ) -> ClosingContextProtocol
    
    public typealias PresenterFactory = (
        UIViewController
    ) -> Presenter
    
    private let assembly: Assembly
    private let resultObserver: PassthroughSubject<Output, Failure>
    private let config: Configuration
    private let context: PresentationContextProtocol
    
    private let presentationConfiguration: NavigationPresentationConfiguration
    
    private let closingContextFactory: ClosingContextFactory
    private let presenterFactory: PresenterFactory
    
    public init(
        assembly: Assembly,
        resultObserver: PassthroughSubject<Output, Failure>,
        config: Configuration,
        context: PresentationContextProtocol,
        presentationConfiguration: NavigationPresentationConfiguration,
        closingContextFactory: @escaping ClosingContextFactory,
        presenterFactory: @escaping PresenterFactory
    ) {
        self.assembly = assembly
        self.resultObserver = resultObserver
        self.config = config
        self.context = context
        self.presentationConfiguration = presentationConfiguration
        self.closingContextFactory = closingContextFactory
        self.presenterFactory = presenterFactory
    }
    
    public func present() {
        guard let navigationController = context.navigationController else {
            return
        }
        
        let closingContext = closingContextFactory(
            resultObserver,
            context,
            presentationConfiguration.animated
        )
        
        let assemblyContext = Assembly.Context(
            resultObserver: resultObserver,
            closingContext: closingContext,
            configuration: config
        )
        
        let viewController = assembly.assemble(assemblyContext)
        
        let presenter = presenterFactory(viewController)
        
        switch presentationConfiguration.type {
        case .push:
            presenter.push(
                in: navigationController,
                animated: presentationConfiguration.animated
            )
            
        case .replace:
            presenter.replaceCurrent(
                in: navigationController,
                animated: presentationConfiguration.animated
            )
            
        case .replaceAll:
            presenter.replaceAll(
                in: navigationController,
                animated: presentationConfiguration.animated
            )
        }
    }
}
