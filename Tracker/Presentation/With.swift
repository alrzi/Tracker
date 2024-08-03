//
//  With.swift
//  Tracker
//
//  Created by Александр Зиновьев on 03.08.2024.
//

import Foundation

/// Создает объект указанного типа, применяет к нему изменения и возвращает его в качестве результата работы
///
/// - Parameters:
///   - type: тип объекта, который нужно создать (должен являться наследником `NSObject`)
///   - changes: изменения, которые нужно применить
///
/// - Returns: объект с примененными изменениями
///
/// Пример использования
///
/// ```swift
/// private lazy var imageView: UIImageView = with {
///     $0.contentMode = .scaleAspectFill
///     $0.image = R.image.amazonBabyRegistryHeader()
/// }
/// ```
public func with<T: NSObject>(
    _ type: T.Type = T.self,
    perform changes: (T) -> Void
) -> T {
    with(T(), perform: changes)
}

/// Применяет изменения к экземпляру класса и возвращает его в качестве результата работы
///
/// - Parameters:
///   - value: экземпляр класса, к которому применяются изменения
///   - changes: изменения, которые нужно применить
///
/// - Returns: экземпляр класса с примененными изменениями
///
/// Пример использования
///
/// ```swift
/// private lazy var imageView = with(UIImageView()) {
///     $0.contentMode = .scaleAspectFill
///     $0.image = R.image.amazonBabyRegistryHeader()
/// }
/// ```
public func with<T: AnyObject>(
    _ value: T,
    perform changes: (T) -> Void
) -> T {
    changes(value)
    return value
}

/// Применяет изменения к объекту и возвращает его в качестве результата работы
///
/// - Parameters:
///   - value: объект, к которому применяются изменения
///   - changes: изменения, которые нужно применить
///
/// - Returns: объект с примененными изменениями
///
/// Пример использования
///
/// ```swift
/// struct ReminderTime {
///     var hours: Int = 0
///     var minutes: Int = 0
/// }
///
/// private lazy var reminderTime = with(value: ReminderTime()) {
///     $0.hours = 12
///     $0.minutes = 30
/// }
/// ```
public func with<T>(
    value: T,
    perform changes: (inout T) -> Void
) -> T {
    var newValue = value
    changes(&newValue)
    return newValue
}
