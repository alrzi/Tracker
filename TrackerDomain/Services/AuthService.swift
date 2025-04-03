import Foundation

public protocol AuthServiceProtocol: Sendable {
    func login() async -> Bool
}

final class AuthService: AuthServiceProtocol {
    private let authDataStorage: AuthDataStorage
    
    init(authDataStorage: AuthDataStorage) {
        self.authDataStorage = authDataStorage
    }
    
    func login() async -> Bool {
        authDataStorage.isUserLoggedIn = true
        
        return authDataStorage.isUserLoggedIn
    }
}
