//
//  DeepLinkError.swift
//  Tracker
//
//  Created by Александр Зиновьев on 12.05.2023.
//

import Foundation

/// Ошибка при обработке ссылок
enum DeepLinkError: Error {
    /// Некорректное «сырое» значение
    case invalidRawValue
}
