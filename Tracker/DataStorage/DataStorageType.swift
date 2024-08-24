//
//  DataStorageType.swift
//  Tracker
//
//  Created by Александр Зиновьев on 24.08.2024.
//

import Foundation

enum DataStorageType {
    /// Сохранение в постоянную память, доступ только из приложения
    case standard
    
    /// Сохранение в постоянную память, доступ из приложения и его сателлитов на устройстве (например, виджет)
    case shared
    
    /// Сохранение в оперативную память, доступ только из приложения
    case session
}
