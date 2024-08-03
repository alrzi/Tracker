//
//  Holder.swift
//  Tracker
//
//  Created by Александр Зиновьев on 03.08.2024.
//

import Foundation

public final class Holder<T: AnyObject> {
    /// Сильная ссылка для удержания объекта
    private var holdingReference: T?
    
    /// Объект, если он все ещё удерживается этим холдером или кем-то ещё
    public private(set) weak var value: T?
    
    /// Создание холдера
    /// - Parameter objectToHold: Объект, который будет удерживаться
    public init(_ objectToHold: T) {
        holdingReference = objectToHold
        value = holdingReference
    }
    
    /// Завершает удержание объекта
    public func dispose() {
        holdingReference = nil
    }
}
