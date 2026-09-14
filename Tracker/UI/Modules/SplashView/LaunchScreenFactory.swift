import SwiftUI

struct LaunchScreenFactory {
    @MainActor
    static func makeView(onAppear: @escaping () async -> Void) -> some View {
        LaunchScreenView(onAppear: onAppear)
    }
}
