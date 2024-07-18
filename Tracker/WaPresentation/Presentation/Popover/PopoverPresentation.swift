//
//  PopoverPresentation.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 18.05.2023.
//

import Foundation
import Combine
import UIKit

public final class PopoverPresentation<Assembly: ViewControllerAssembly>: Presentable
where Assembly.Context: LifecycleManagingContextProtocol {
    public typealias Output = Assembly.Context.Output
    public typealias Failure = Assembly.Context.Failure
    public typealias Configuration = Assembly.Context.Configuration
    
    private let assembly: Assembly
    private let resultObserver: PassthroughSubject<Output, Failure>
    private let configuration: Configuration
    private let presentationContext: PresentationContextProtocol
    
    private let presentationConfiguration: PopoverPresentationConfiguration
    
    private let holder = Holder()
    
    public init(
        assembly: Assembly,
        resultObserver: PassthroughSubject<Output, Failure>,
        configuration: Configuration,
        presentationContext: PresentationContextProtocol,
        presentationConfiguration: PopoverPresentationConfiguration
    ) {
        self.assembly = assembly
        self.resultObserver = resultObserver
        self.configuration = configuration
        self.presentationContext = presentationContext
        self.presentationConfiguration = presentationConfiguration
    }
    
    public func present() {
        guard let presentingViewController = presentationContext.viewController else {
            return
        }
        
        let context = Assembly.Context(
            resultObserver: resultObserver,
            closingContext: ModalClosingContext(
                presentationContext: presentationContext,
                animated: presentationConfiguration.animated
            ),
            configuration: configuration
        )
        
        let viewController = assembly.assemble(context)
        
        viewController.modalPresentationStyle = .popover
        
        let controller = viewController.popoverPresentationController
        
        let holder = Holder()
        
        let delegate = PresentationControllerDelegate { [resultObserver] in
            resultObserver.send(completion: .finished)
            holder.delegate = nil
        }
        
        holder.delegate = delegate
        
        controller?.permittedArrowDirections = presentationConfiguration.arrowDirections
        switch presentationConfiguration.source {
        case .barButton(let barButtonItem):
            controller?.barButtonItem = barButtonItem

        case .source(let source):
            controller?.sourceView = source.view
            controller?.sourceRect = source.rect
        }
        
        controller?.delegate = delegate
        controller?.backgroundColor = presentationConfiguration.backgroundColor
        
        let presenter = DefaultModalPresenter(
            viewController: viewController,
            presentationStyle: .popover,
            transitionStyle: .coverVertical
        )
        
        presenter.present(
            at: presentingViewController,
            animated: presentationConfiguration.animated
        ) { [presentationConfiguration] in
            controller?.passthroughViews = presentationConfiguration.passthroughViews
        }
    }
}

private extension PopoverPresentation {
    final class Holder {
        var delegate: UIPopoverPresentationControllerDelegate?
    }
}

private extension PopoverPresentation {
    private final class PresentationControllerDelegate: NSObject, UIPopoverPresentationControllerDelegate {
        private let onDismiss: () -> Void
        
        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }
        
        func adaptivePresentationStyle(
            for controller: UIPresentationController
        ) -> UIModalPresentationStyle {
            return .none
        }
        
        func popoverPresentationControllerDidDismissPopover(
            _ popoverPresentationController: UIPopoverPresentationController
        ) {
            onDismiss()
        }
    }
}
