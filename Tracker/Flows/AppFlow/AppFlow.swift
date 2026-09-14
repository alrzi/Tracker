import Observation
import TrackerDomain

@MainActor
@Observable
final class AppFlow {
    enum State {
        case launching
        case main
    }

    private let authService: any AuthServiceProtocol
    @ObservationIgnored private var loginTask: Task<Void, Never>?

    private(set) var state: State = .launching

    init(authService: some AuthServiceProtocol) {
        self.authService = authService
    }

    func start() async {
        if let loginTask {
            await loginTask.value
            return
        }

        let task = Task { @MainActor [weak self] in
            guard let self, await authService.login() else { return }
            state = .main
        }
        loginTask = task
        await task.value
    }
}
