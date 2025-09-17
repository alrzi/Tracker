//
//  DeepLinkHandlerProtocol.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.09.2020.
//

import Foundation

/// Обработчик ссылок
public protocol DeepLinkHandlerProtocol<Link>: RawValueHandlerProtocol
where RawValue == Link.RawValue {
    /// Тип ссылки, которую можно обработать
    associatedtype Link: DeepLinkProtocol
    
    /// Обрабатывает ссылку и возвращает результат обработки
    ///
    /// - Parameters:
    ///    - link: ссылка, которую нужно обработать
    ///
    /// - Returns: результат обработки
    func handle(link: Link) -> HandlingResult
}

public extension DeepLinkHandlerProtocol {
    func attemptHandle(rawValue: RawValue) -> HandlingResult {
        guard let link = Link(rawValue: rawValue) else {
            return .notHandled(DeepLinkError.invalidRawValue)
        }
        
        return handle(link: link)
    }
}
