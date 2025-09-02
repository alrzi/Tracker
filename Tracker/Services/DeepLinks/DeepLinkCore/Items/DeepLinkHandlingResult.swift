//
//  DeepLinkHandlingResult.swift
//  Tracker
//
//  Created by Александр Зиновьев on 12.05.2023.
//

import Foundation

/// Результат обработки ссылок
public enum DeepLinkHandlingResult {
    /// Ссылка успешно обработана
    case success
    
    /// Запланирована обработка ссылки
    case enqueued
    
    /// При обработке ссылки произошла ошибка
    case failed
}
