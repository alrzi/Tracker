//
//  DeepLinkServiceProtocol.swift
//  Tracker
//
//  Created by Александр Зиновьев on 15.09.2020.
//

import Foundation

/// Сервис обработки ссылок
public protocol DeepLinkServiceProtocol<RawValue> {
    /// Тип «сырого» значения, которое может быть обработано этим сервисом
    associatedtype RawValue
    
    /// Регистрирует обработчик ссылок
    ///
    /// - Parameters:
    ///    - handler: обработчик ссылок, который нужно зарегистрировать
    ///
    func register<Handler>(
        handler: Handler
    ) where Handler: DeepLinkHandlerProtocol, Handler.RawValue == RawValue
    
    /// Обрабатывает «сырое» значение ссылки
    ///
    /// - Parameters:
    ///    - rawValue: «сырое» значение, которое нужно обработать
    ///
    /// - Returns: результат обработки
    @discardableResult
    func handle(rawValue: RawValue) -> DeepLinkHandlingResult
}
