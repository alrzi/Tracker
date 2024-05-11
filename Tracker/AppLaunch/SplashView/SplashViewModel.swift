final class SplashViewModel {
    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    func isUserLoggedIn() -> Bool {
        return authService.isLoggedIn
    }

    func loginUser(completion: @escaping () -> Void) {
        authService.login { success in
            if success {
                completion()
            }
        }
    }
}
