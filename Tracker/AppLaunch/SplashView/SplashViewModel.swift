final class SplashViewModel {
    private let authService: AuthService
    private let router: SplashViewRouter

    init(
        authService: AuthService,
        router: SplashViewRouter
    ) {
        self.authService = authService
        self.router = router
    }

    func isUserLoggedIn() -> Bool {
        return authService.isLoggedIn
    }

    func loginUser() {
        authService.login { [router] isLoggedIn in
            if isLoggedIn {
                router.showTabBar()
            }
        }
    }
}
