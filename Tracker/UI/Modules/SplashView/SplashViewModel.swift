import TrackerDomain

@MainActor
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
        Task {
            let isLoggedIn = await authService.login()
            
            if isLoggedIn {
                router.showTabBar()
            }
        }
    }
}
