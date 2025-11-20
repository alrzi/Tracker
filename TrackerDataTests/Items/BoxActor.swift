//
//  BoxActor.swift
//  TrackerDataTests
//
//  Created by Александр Зиновьев on 20.11.2025.
//

import Foundation

actor BoxActor<Value> {
    /// Значение, лежащее в контейнере
    private(set) var value: Value

    /// Создание контейнера значения с семантикой ссылочного типа
    /// - Parameter value: Значение, лежащее в контейнере
    init(_ value: Value) {
        self.value = value
    }

    /// Записывает новое значение в контейнер
    /// - Parameter value: Значение, которое будет сохранено в контейнере
    func setValue(_ value: Value) {
        self.value = value
    }
}
