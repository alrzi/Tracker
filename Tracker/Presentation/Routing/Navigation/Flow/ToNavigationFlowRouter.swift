//
//  ToNavigationFlowRouter.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 03.05.2024.
//

import UIKit
import Combine

public struct ToNavigationFlowRouter<PresentationContext, Output, Failure>
    where
        PresentationContext: PresentationContextProtocol,
        Failure: Error
{
    public typealias FlowFactory = (NavigationPresentationContext) -> AnyPublisher<Output, Failure>
    public typealias PresentClosure = (UIViewController, PresentationContext) -> Void
    public typealias SetupNavigationClosure = (UINavigationController) -> Void
    
    private let flowFactory: FlowFactory
    private let present: PresentClosure
    private let setupNavigation: SetupNavigationClosure
    private let presentationContext: PresentationContext
    
    public init(
        presentationContext: PresentationContext,
        present: @escaping PresentClosure,
        setupNavigation: @escaping SetupNavigationClosure,
        flowFactory: @escaping FlowFactory
    ) {
        self.presentationContext = presentationContext
        self.present = present
        self.setupNavigation = setupNavigation
        self.flowFactory = flowFactory
    }
    
    public func route() -> AnyPublisher<Output, Failure> {
        Future<UINavigationController, Never> { promise in
            promise(.success(with { setupNavigation($0) }))
        }
        .receive(on: DispatchQueue.main)
        .handleEvents(receiveOutput: { present($0, presentationContext) })
        .map { NavigationPresentationContext(navigationController: $0) }
        .flatMap { presentationContext in
            let holder = Holder(NavigationControllerDelegate())
            
            return flowFactory(presentationContext)               
                .handleEvents(
                    receiveSubscription: { _ in presentationContext.navigationController?.delegate = holder.value },
                    receiveCompletion: { _ in holder.dispose() }
                )
        }
        .eraseToAnyPublisher()
    }
}

extension ToNavigationFlowRouter {
    public static func modal(
        presentationContext: PresentationContext,
        presentationStyle: ModalPresentationStyle,
        transitionStyle: ModalTransitionStyle,
        setupNavigation: @escaping SetupNavigationClosure,
        flowFactory: @escaping FlowFactory
    ) -> Self {
        .init(
            presentationContext: presentationContext,
            present: { viewController, context in
                guard let presentingViewController = context.viewController else {
                    assertionFailure("Передан контекст без установленного вьюконтроллера")
                    return
                }
                
                DefaultModalPresenter(
                    viewController: viewController,
                    presentationStyle: presentationStyle,
                    transitionStyle: transitionStyle
                )
                .present(at: presentingViewController, animated: true)
            },
            setupNavigation: setupNavigation,
            flowFactory: { context in
                flowFactory(context)
                    .handleEvents(
                        receiveCompletion: { _ in context.navigationController?.dismiss(animated: true) }
                    )
                    .eraseToAnyPublisher()
            }
        )
    }
}

extension ToNavigationFlowRouter where PresentationContext == WindowPresentationContext {
    public static func window(
        presentationContext: PresentationContext,
        setupNavigation: @escaping SetupNavigationClosure,
        flowFactory: @escaping FlowFactory
    ) -> Self {
        .init(
            presentationContext: presentationContext,
            present: { viewController, context in
                guard let window = context.window else {
                    assertionFailure("Передан контекст без установленного окна")
                    return
                }
                
                DefaultWindowPresenter(viewController).present(at: window)
            },
            setupNavigation: setupNavigation,
            flowFactory: flowFactory
        )
    }
}

private extension ToNavigationFlowRouter {
    final class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
        func navigationController(
            _ navigationController: UINavigationController,
            willShow viewController: UIViewController,
            animated: Bool
        ) {
            viewController.navigationItem.backButtonDisplayMode = .minimal
        }
    }
}
