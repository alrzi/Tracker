import SwiftUI

struct LaunchScreenView: View {
    let onAppear: () async -> Void

    var body: some View {
        Color(.cBlue)
            .ignoresSafeArea()
            .task { await onAppear() }
    }
}
