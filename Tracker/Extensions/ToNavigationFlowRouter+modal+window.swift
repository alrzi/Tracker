//
//  ToNavigationFlowRouter+modal+window.swift
//  Tracker
//
//  Created by Александр Зиновьев on 03.08.2024.
//

import UIKit

extension ToNavigationFlowRouter {
    static func modal(
        presentationContext: PresentationContext,
        presentationStyle: ModalPresentationStyle,
        transitionStyle: ModalTransitionStyle,
        flowFactory: @escaping FlowFactory
    ) -> Self {
        .modal(
            presentationContext: presentationContext,
            presentationStyle: presentationStyle,
            transitionStyle: transitionStyle,
            setupNavigation: { Self.setupNavigation(controller: $0) },
            flowFactory: flowFactory
        )
    }
}

extension ToNavigationFlowRouter where PresentationContext == WindowPresentationContext {
    static func window(
        presentationContext: PresentationContext,
        flowFactory: @escaping FlowFactory
    ) -> Self {
        .window(
            presentationContext: presentationContext,
            setupNavigation: { Self.setupNavigation(controller: $0) },
            flowFactory: flowFactory
        )
    }
}

private extension ToNavigationFlowRouter {
    static func setupNavigation(controller: UINavigationController) {
//        controller.setNavigationBarHidden(true, animated: false)
        controller.hideKeyboardWhenTappedAround()
        controller.navigationItem.leftBarButtonItem = nil
        controller.navigationController?.navigationBar.items = []
    }
}
