import SwiftUI

@main
@MainActor
struct TrackerApp: App {
    @Environment(\.scenePhase) private var scenePhase

    private let compositionRoot: AppCompositionRoot

    @State private var notificationSyncTask: Task<Void, Never>?

    init() {
        compositionRoot = AppCompositionRoot()
    }

    var body: some Scene {
        WindowGroup {
            AppFlowContainer(dependencies: compositionRoot.appFlowDependencies)
                .onChange(of: scenePhase) { _, phase in
                    guard phase == .active else {
                        return
                    }

                    notificationSyncTask?.cancel()
                    notificationSyncTask = Task {
                        do {
                            try await compositionRoot.notificationManager.sync()
                        } catch is CancellationError {
                            return
                        } catch {
                            print("[TrackerApp] Notification sync failed: \(error.localizedDescription)")
                        }
                    }
                }
        }
    }
}
