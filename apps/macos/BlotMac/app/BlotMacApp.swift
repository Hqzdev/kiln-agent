//
//  BlotMacApp.swift
//  blot-agent
//
//  Created by Yaroslav Fairfieldd on 10/11/26.
//

import SwiftUI

@main
struct BlotMacApp: App {
    @NSApplicationDelegateAdaptor(BlotBackendLifecycle.self) private var lifecycle
    @State private var state = AppState()

    init() {
        FontRegistrar.registerBundledFonts()
    }

    var body: some Scene {
        WindowGroup {
            BlotWindowContent(state: state)
                .task { await state.restoreBackendSession() }
                .sheet(isPresented: $state.showDevicePairing) { DevicePairingView() }
        }
        .windowStyle(.hiddenTitleBar)
        .windowBackgroundDragBehavior(.enabled)
        .defaultSize(width: K.windowWidth, height: K.windowHeight)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button(state.product == .work ? "New chat" : state.isMotes ? "New run" : "New task") { state.openNewItem() }
                    .keyboardShortcut("n")
                    .disabled(!state.isSignedIn)
            }
            CommandGroup(replacing: .appSettings) {
                Button("Settings…") { state.showingSettings = true }
                    .keyboardShortcut(",")
                    .disabled(!state.isSignedIn)
            }
            CommandMenu("Go") {
                Button("Search tasks, files and actions…") {
                    if state.paletteVisible { state.paletteVisible = false }
                    else { state.openCommandPalette() }
                }
                .keyboardShortcut("k")
                .disabled(!state.isSignedIn)
                Divider()
                Button("Blot Code · New task") { state.openHome() }
                    .keyboardShortcut("1")
                Button("Motes · Team chat") {
                    state.openWorkRun(state.selectedRunID)
                }
                .keyboardShortcut("2")
                Button("Motes · Team graph") { state.openGraph() }
                    .keyboardShortcut("3")
                Divider()
                Button("Show Pet") { state.openPet() }
                    .keyboardShortcut(" ", modifiers: .option)
                    .disabled(!state.isSignedIn)
                Button(state.sidebarVisible ? "Hide Sidebar" : "Show Sidebar") {
                    state.sidebarVisible.toggle()
                }
                .keyboardShortcut("s", modifiers: [.command, .control])
            }
            CommandMenu("Devices") {
                Button("Connect iPhone…") { state.showDevicePairing = true }.disabled(!state.isSignedIn)
            }
            CommandMenu("Theme") {
                ForEach(ThemePreference.allCases) { theme in
                    Button(theme.rawValue) { state.theme = theme }
                }
            }
        }
        WindowGroup("Conversation", for: ConversationWindowRequest.self) { request in
            if let value = request.wrappedValue {
                ConversationWindowView(request: value).environment(state)
            }
        }
        .defaultSize(width: 760, height: 700)
    }
}

@MainActor
final class BlotBackendLifecycle: NSObject, NSApplicationDelegate {
    func applicationWillTerminate(_ notification: Notification) { BackendRuntime.shared.stop() }
}
