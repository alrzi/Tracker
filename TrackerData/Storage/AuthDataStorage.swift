//
//  AuthDataStorage.swift
//  Tracker
//
//  Created by Александр Зиновьев on 25.08.2024.
//

import Foundation
import TrackerDomain
internal import DataStorage

extension AuthDataStorage where Self: DataStorageProtocol {
    var isUserLoggedIn: Bool {
        get {
            getValue(key: Key.isUserLoggedIn, storage: .default) ?? false
        }
        set {
            setValue(key: Key.isUserLoggedIn, value: newValue, storage: .default)
        }
    }
}

extension DataStorage: @retroactive AuthDataStorage { }

private enum Key: String, DataStorageKey {
    case isUserLoggedIn
}
