//
//  DeepLinkServiceFactory.swift
//  Tracker
//
//  Created by Александр Зиновьев on 12.05.2023.
//

import Foundation

/// Фабрика сервиса обработки ссылок
public final class DeepLinkServiceFactory {
    public init() { }
    
    /// Создает сервис обработки ссылок
    ///
    /// - Parameters:
    ///    - type: тип «сырого» значения, которое может быть обработано этим сервисом
    ///
    /// - Returns: сервис обработки ссылок
    public func create<RawValue>(
        type: RawValue.Type = RawValue.self
    ) -> some DeepLinkServiceProtocol<RawValue>
    where RawValue: Hashable {
        DeepLinkService()
    }
}
