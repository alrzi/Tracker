//
//  ViewControllerAssembly.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 30.08.2022.
//

import UIKit
import Combine
import Combine

public protocol ViewControllerAssembly {
    associatedtype ViewController: UIViewController
    associatedtype Context
    
    /// Собирает модуль и возвращает `ViewController`
    /// - Parameters:
    ///   - context: контекст сборки модуля
    ///
    /// - Returns: `ViewController` соответствующего модуля
    func assemble(
        _ context: Context
    ) -> ViewController
}

public extension ViewControllerAssembly where Context == () {
    func assemble() -> ViewController {
        return assemble(())
    }
}

public extension ViewControllerAssembly where Context: LifecycleManagingContextProtocol {
    typealias Output = Context.Output
    typealias Failure = Context.Failure
    typealias Configuration = Context.Configuration
    
    /// Собирает модуль и возвращает `ViewController`
    /// - Parameters:
    ///   - resultObserver: объект, позволяющий отправлять целевые действия из модуля во внешний мир
    ///   - closingContext: объект, позволяющий завершить работу модуля
    ///   - configuration: входные параметры модуля
    ///
    /// - Returns: `ViewController` соответствующего модуля
    func assemble(
        resultObserver: PassthroughSubject<Output, Failure>,
        closingContext: ClosingContextProtocol,
        _ configuration: Configuration
    ) -> ViewController {
        let context = Context(
            resultObserver: resultObserver,
            closingContext: closingContext,
            configuration: configuration
        )
        
        return assemble(context)
    }
}

public extension ViewControllerAssembly where Context: LifecycleManagingContextProtocol, Context.Configuration == () {
    func assemble(
        resultObserver: PassthroughSubject<Output, Failure>,
        closingContext: ClosingContextProtocol
    ) -> ViewController {
        assemble(resultObserver: resultObserver, closingContext: closingContext, ())
    }
}
