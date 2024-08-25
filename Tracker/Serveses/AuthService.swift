import Foundation

protocol AuthServiceProtocol {
    func login(completion: @escaping (Bool) -> Void)
}

final class AuthService: AuthServiceProtocol {
    private let authDataStorage: AuthDataStorage
    
    init(authDataStorage: AuthDataStorage) {
        self.authDataStorage = authDataStorage
    }
    
    func login(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [authDataStorage] in
            authDataStorage.isUserLoggedIn = true
            
            completion(true)
        }
    }
}
