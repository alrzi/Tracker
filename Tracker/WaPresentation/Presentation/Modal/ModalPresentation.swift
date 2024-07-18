//
//  ModalPresentation.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 30.08.2022.
//

import Foundation
import Combine
import UIKit

public final class ModalPresentation<Assembly: ViewControllerAssembly>: Presentable
where Assembly.Context: LifecycleManagingContextProtocol {
    public typealias Output = Assembly.Context.Output
    public typealias Failure = Assembly.Context.Failure
    public typealias Configuration = Assembly.Context.Configuration
    
    public typealias ClosingContextFactory = (
        PassthroughSubject<Assembly.Output, Assembly.Failure>,
        PresentationContextProtocol,
        Bool
    ) -> ClosingContextProtocol
    
    private let assembly: Assembly
    private let resultObserver: PassthroughSubject<Output, Failure>
    private let config: Configuration
    private let context: PresentationContextProtocol
    
    private let closingContextFactory: ClosingContextFactory
    
    private let presentationConfiguration: ModalPresentationConfiguration
    
    private let holder = Holder()
    
    public init(
        assembly: Assembly,
        resultObserver: PassthroughSubject<Output, Failure>,
        config: Configuration,
        context: PresentationContextProtocol,
        presentationConfiguration: ModalPresentationConfiguration,
        closingContextFactory: @escaping ClosingContextFactory
    ) {
        self.assembly = assembly
        self.resultObserver = resultObserver
        self.config = config
        self.context = context
        self.presentationConfiguration = presentationConfiguration
        self.closingContextFactory = closingContextFactory
        
        if case .sizeClassDependent = presentationConfiguration.presentationStyle {
            holder.delegate = TransitioningDelegate()
        }
    }
    
    public func present() {
        guard let presentingViewController = context.viewController else {
            return
        }
        
        let context = Assembly.Context(
            resultObserver: resultObserver,
            closingContext: closingContextFactory(resultObserver, context, presentationConfiguration.animated),
            configuration: config
        )
        
        let viewController = assembly.assemble(context)
        
        if case .sizeClassDependent = presentationConfiguration.presentationStyle {
            viewController.transitioningDelegate = holder.delegate
            viewController.preferredContentSize = CGSize(width: 556, height: 786)
        }
        
        viewController.popoverPresentationController?.sourceView = presentingViewController.view
        
        // Так как мы не можем получить позицию конкретной вью из SwiftUI,
        // будем показывать все поповеры на iPad сверху по центру
        let layoutFrame = presentingViewController.view.safeAreaLayoutGuide.layoutFrame
        let rect = CGRect(
            origin: CGPoint(x: layoutFrame.midX, y: layoutFrame.minY),
            size: .zero
        )
        
        viewController.popoverPresentationController?.sourceRect = rect
        
        let presenter = DefaultModalPresenter(
            viewController: viewController,
            presentationStyle: presentationConfiguration.presentationStyle,
            transitionStyle: presentationConfiguration.transitionStyle
        )
        
        presenter.present(at: presentingViewController, animated: true) { [holder] in
            holder.delegate = nil
        }
    }
}

private extension ModalPresentation {
    class Holder {
        var delegate: UIViewControllerTransitioningDelegate?
    }
}

private class TransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let controller = PresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
        
        return controller
    }
}

private class PresentationController: UIPresentationController {
    override func adaptivePresentationStyle(
        for traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        if traitCollection.horizontalSizeClass == .regular {
            return .formSheet
        }
        else {
            return .fullScreen
        }
    }
}
