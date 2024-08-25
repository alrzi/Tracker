//
//  AuthDataStorage.swift
//  Tracker
//
//  Created by Александр Зиновьев on 25.08.2024.
//

import Foundation
import DataStorage

protocol AuthDataStorage: AnyObject {
    var isUserLoggedIn: Bool { get set }
}

extension AuthDataStorage where Self: DataStorageProtocol {
    var isUserLoggedIn: Bool {
        get {
            getValue(key: AuthDataStorageKey.isUserLoggedIn, storage: .standard) ?? false
        }
        set {
            setValue(key: AuthDataStorageKey.isUserLoggedIn, value: newValue, storage: .standard)
        }
    }
}

extension DataStorage: AuthDataStorage { }

private enum AuthDataStorageKey: String, DataStorageKey {
    case isUserLoggedIn
}
