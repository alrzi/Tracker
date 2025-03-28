import TrackerDomain

final class SplashViewModel {
    private let authService: AuthServiceProtocol
    private let router: SplashViewRouter

    init(
        authService: AuthServiceProtocol,
        router: SplashViewRouter
    ) {
        self.authService = authService
        self.router = router
    }

    func loginUser() {
        authService.login { [router] isLoggedIn in
            if isLoggedIn {
                router.showTabBar()
            }
        }
    }
}
