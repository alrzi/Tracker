//
//  AuthDataStorage.swift
//  Tracker
//
//  Created by Александр Зиновьев on 25.08.2024.
//

import Foundation
import TrackerDomain
import KeyValueStorage

extension KeyValueStorageProtocol where Self: AuthDataStorage {
    public var isUserLoggedIn: Bool {
        get { fetch(UserLoggedInKey.self) }
        set { save(newValue, for: UserLoggedInKey.self) }
    }
}

extension UserDefaults: @retroactive AuthDataStorage { }

private enum UserLoggedInKey: StorageKey {
    typealias Value = Bool
    
    static let name = "com.app.auth.isUserLoggedIn"
    static let defaultValue = false
}
