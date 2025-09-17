//
//  HandlingResult.swift
//  Tracker
//
//  Created by Александр Зиновьев on 12.05.2023.
//

import Foundation

/// Результат работы обработчика ссылок
public enum HandlingResult {
    /// Обработана
    case handled
    
    /// Частично обработана
    case partiallyHandled
    
    /// Не обработана
    case notHandled(Error?)
}
