import Foundation

final class AuthService {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults()) {
        self.userDefaults = userDefaults
    }
    
    enum Key: String {
        case isLogin
    }
    
    var isLoggedIn: Bool {
        get {
            userDefaults.bool(forKey: Key.isLogin.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Key.isLogin.rawValue)
        }
    }
    
    func login(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.isLoggedIn = true
            completion(true)
        }
    }
}
