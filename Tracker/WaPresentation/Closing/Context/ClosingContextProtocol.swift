//
//  ClosingContextProtocol.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 30.08.2022.
//

import Foundation

/// Контекст закрытия, завершающий работу модуля
public protocol ClosingContextProtocol {
    /// Завершает работу модуля
    ///
    /// - Parameters:
    ///    - completion: функция, вызывающаяся после закрытия модуля
    func close(completion: (() -> Void)?)
}

public extension ClosingContextProtocol {
    /// Завершает работу модуля
    func close() {
        close(completion: nil)
    }
}
