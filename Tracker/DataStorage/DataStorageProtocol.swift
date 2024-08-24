//
//  DataStorageProtocol.swift
//  Tracker
//
//  Created by Александр Зиновьев on 24.08.2024.
//

import Foundation

protocol DataStorageProtocol {
    func getValue<T>(
        key: DataStorageKey,
        storage: DataStorageType
    ) -> T?
    
    func setValue<T>(
        key: DataStorageKey,
        value: T,
        storage: DataStorageType
    )
    
    func clean(
        key: DataStorageKey,
        storage: DataStorageType
    )
    
    func getCodableValue<T: Codable>(key: DataStorageKey, storage: DataStorageType) -> T?
    
    func setCodableValue<T: Codable>(_ newValue: T, key: DataStorageKey, storage: DataStorageType)
}

extension DataStorageProtocol {
    func setOptionalValue<T>(
        key: DataStorageKey,
        value: T?,
        storage: DataStorageType
    ) {
        if let value {
            setValue(key: key, value: value, storage: storage)
        }
        else {
            clean(key: key, storage: storage)
        }
    }
    
    func setOptionalCodableValue<T: Codable>(_ newValue: T?, key: DataStorageKey, storage: DataStorageType) {
        if let newValue {
            setCodableValue(newValue, key: key, storage: storage)
        }
        else {
            clean(key: key, storage: storage)
        }
    }
}
