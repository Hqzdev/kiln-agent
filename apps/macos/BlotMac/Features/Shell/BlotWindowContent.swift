import SwiftUI

/// Apply shared state outside the entire window tree, including auxiliary background views.
struct BlotWindowContent: View {
    let state: AppState

    var body: some View {
        RootView()
            .background(DockIconSync())
            .environment(state)
            .preferredColorScheme(state.theme.colorScheme)
            .frame(minWidth: 1100, minHeight: 666)
    }
}
