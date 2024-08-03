import Foundation

final class AuthService {
    private let userDefaults: UserDefaults
    
    var isLoggedIn: Bool {
        get {
            userDefaults.bool(forKey: Key.isLogin.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Key.isLogin.rawValue)
        }
    }
    
    init(userDefaults: UserDefaults = UserDefaults()) {
        self.userDefaults = userDefaults
    }
   
    func login(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoggedIn = true
            completion(true)
        }
    }
}

private extension AuthService {
    enum Key: String {
        case isLogin
    }
}
