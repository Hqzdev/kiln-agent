import SwiftUI
import AppKit
import Virtualization
import UniformTypeIdentifiers

struct VirtualMachineSettingsView: View {
    @State private var preparation = VirtualMachinePreparation.shared
    @State private var error: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Среда выполнения macOS").font(.title2)
            Text("Команды выполняются в отдельной VM: 4 CPU, 8 ГБ памяти, диск до 128 ГБ. Рабочие задания не имеют сети. Для первого запуска нужен IPSW macOS и установка инструментов в гостевой системе.")
            HStack {
                Button("Установить из IPSW…") { chooseImage() }.disabled(preparation.isBusy || preparation.machine != nil)
                Button("Подготовить инструменты") { perform { try await preparation.prepare() } }.disabled(preparation.isBusy || preparation.machine != nil)
                Button("Сохранить образ") { perform { try await preparation.seal() } }.disabled(preparation.machine == nil || preparation.isBusy)
            }
            Text("В гостевой macOS откройте Terminal и выполните: sudo sh '/Volumes/My Shared Files/bootstrap/install-guest.sh'. Затем установите JDK 25, Xcode и зависимости проектов. Не входите в личные аккаунты. Перед сохранением закройте программы и файлы.")
                .textSelection(.enabled)
            if preparation.isBusy { ProgressView() }
            Text(preparation.message).foregroundStyle(.secondary)
            if let error { Text(error).foregroundStyle(.red).textSelection(.enabled) }
            if let machine = preparation.machine { GuestScreen(machine: machine).frame(minWidth: 640, minHeight: 420) }
        }
    }
    private func chooseImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "ipsw") ?? .data]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        perform { try await preparation.install(from: url) }
    }
    private func perform(_ action: @escaping @MainActor () async throws -> Void) {
        error = nil
        _Concurrency.Task { do { try await action() } catch { self.error = error.localizedDescription } }
    }
}
private struct GuestScreen: NSViewRepresentable {
    let machine: VZVirtualMachine
    func makeNSView(context: Context) -> VZVirtualMachineView { let view = VZVirtualMachineView(); view.virtualMachine = machine; view.capturesSystemKeys = true; return view }
    func updateNSView(_ view: VZVirtualMachineView, context: Context) { view.virtualMachine = machine }
}
