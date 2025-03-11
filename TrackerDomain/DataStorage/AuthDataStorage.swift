//
//  AuthDataStorage.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 10.03.2025.
//

import Foundation

public protocol AuthDataStorage: AnyObject {
    var isUserLoggedIn: Bool { get set }
}
