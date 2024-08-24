//
//  DataStorage.swift
//  Tracker
//
//  Created by Александр Зиновьев on 24.08.2024.
//

import Foundation

final class DataStorage: DataStorageProtocol {
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    private let userDefaults: UserDefaults
    private let sharedUserDefaults: UserDefaults
    private let sessionStorage = SessionStorage()
    
    init(
        jsonDecoder: JSONDecoder,
        jsonEncoder: JSONEncoder,
        userDefaults: UserDefaults,
        sharedUserDefaults: UserDefaults
    ) {
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
        self.userDefaults = userDefaults
        self.sharedUserDefaults = sharedUserDefaults
    }
    
    func getValue<T>(key: DataStorageKey, storage: DataStorageType) -> T? {
        userDefaults(for: storage).value(forKey: key.rawValue) as? T
    }
    
    func setValue<T>(
        key: DataStorageKey,
        value: T,
        storage: DataStorageType
    ) {
        userDefaults(for: storage).set(value, forKey: key.rawValue)
    }
    
    func clean(key: DataStorageKey, storage: DataStorageType) {
        userDefaults(for: storage).set(nil, forKey: key.rawValue)
    }
    
    func getCodableValue<T: Codable>(key: DataStorageKey, storage: DataStorageType) -> T? {
        guard let data: Data = getValue(key: key, storage: .standard) else {
            return nil
        }
        
        return try? jsonDecoder.decode(T.self, from: data)
    }
    
    func setCodableValue<T: Codable>(_ newValue: T, key: DataStorageKey, storage: DataStorageType) {
        guard let data = try? jsonEncoder.encode(newValue) else {
            return
        }
        
        setValue(key: key, value: data, storage: storage)
    }
    
    private func userDefaults(for type: DataStorageType) -> StorageProtocol {
        switch type {
        case .shared: return sharedUserDefaults
        case .standard: return userDefaults
        case .session: return sessionStorage
        }
    }
}

extension UserDefaults: StorageProtocol { }

private protocol StorageProtocol {
    func value(forKey key: String) -> Any?
    func set(_ value: Any?, forKey key: String)
}

private extension DataStorage {
    class SessionStorage: StorageProtocol {
        private var data: [String: Any] = [:]
        
        func value(forKey key: String) -> Any? {
            data[key]
        }
        
        func set(_ value: Any?, forKey key: String) {
            data[key] = value
        }
    }
}
