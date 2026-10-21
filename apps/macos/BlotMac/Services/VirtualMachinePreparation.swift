import Foundation
import Observation
import Virtualization
import Darwin

/// Подготовка базовой macOS выполняется владельцем Mac отдельно от агентных заданий.
@MainActor @Observable
final class VirtualMachinePreparation {
    static let shared = VirtualMachinePreparation()
    private(set) var machine: VZVirtualMachine?
    private(set) var isBusy = false
    private(set) var message = ""
    private var installer: VZMacOSInstaller?
    var isReady: Bool { FileManager.default.fileExists(atPath: VirtualMachineConfiguration.base.appendingPathComponent("Ready.json").path) }

    func install(from ipsw: URL) async throws {
        guard !isBusy, !VirtualMachineExecution.shared.isBusy else { throw VirtualMachineConfiguration.error("VM уже используется") }
        let root = VirtualMachineConfiguration.base
        guard !FileManager.default.fileExists(atPath: root.path) else { throw VirtualMachineConfiguration.error("Базовый образ уже существует") }
        isBusy = true; message = "Установка macOS…"
        defer { isBusy = false; installer = nil }
        let access = ipsw.startAccessingSecurityScopedResource()
        defer { if access { ipsw.stopAccessingSecurityScopedResource() } }
        let image = try await VZMacOSRestoreImage.image(from: ipsw)
        guard let requirements = image.mostFeaturefulSupportedConfiguration else { throw VirtualMachineConfiguration.error("Этот IPSW не поддерживается вашим Mac") }
        guard requirements.minimumSupportedMemorySize <= 8 * 1024 * 1024 * 1024,
              requirements.minimumSupportedCPUCount <= 4 else { throw VirtualMachineConfiguration.error("Образу нужно больше ресурсов, чем настроено для VM") }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        try requirements.hardwareModel.dataRepresentation.write(to: root.appendingPathComponent("HardwareModel.bin"))
        try VZMacMachineIdentifier().dataRepresentation.write(to: root.appendingPathComponent("MachineIdentifier.bin"))
        _ = try VZMacAuxiliaryStorage(creatingStorageAt: root.appendingPathComponent("AuxiliaryStorage.bin"), hardwareModel: requirements.hardwareModel, options: [])
        let disk = root.appendingPathComponent("Disk.img")
        let descriptor = open(disk.path, O_CREAT | O_EXCL | O_RDWR, 0o600)
        guard descriptor >= 0 else { throw VirtualMachineConfiguration.error("Не удалось создать диск VM") }
        let resized = ftruncate(descriptor, 128 * 1024 * 1024 * 1024)
        close(descriptor)
        guard resized == 0 else { throw VirtualMachineConfiguration.error("Недостаточно места для VM") }
        let vm = VZVirtualMachine(configuration: try VirtualMachineConfiguration.make(directory: root, shares: [:]))
        machine = vm
        let installer = VZMacOSInstaller(virtualMachine: vm, restoringFromImageAt: ipsw)
        self.installer = installer
        do { try await installer.install(); machine = nil; message = "macOS установлена. Откройте подготовку и установите инструменты." }
        catch { machine = nil; message = error.localizedDescription; throw error }
    }

    func prepare() async throws {
        guard !isBusy, machine == nil, !VirtualMachineExecution.shared.isBusy,
              let bootstrap = Bundle.main.resourceURL?.appendingPathComponent("Backend/Guest") else { throw VirtualMachineConfiguration.error("VM уже используется") }
        isBusy = true
        defer { isBusy = false }
        try? FileManager.default.removeItem(at: VirtualMachineConfiguration.base.appendingPathComponent("Ready.json"))
        let vm = VZVirtualMachine(configuration: try VirtualMachineConfiguration.make(directory: VirtualMachineConfiguration.base,
            shares: ["bootstrap": VZSharedDirectory(url: bootstrap, readOnly: true)], network: true))
        machine = vm
        do { try await vm.start(); message = "Завершите настройку macOS и установите гостевой runner, JDK и Xcode." }
        catch { machine = nil; throw error }
    }

    func seal() async throws {
        guard let machine, machine.state == .running else { throw VirtualMachineConfiguration.error("Откройте подготовку VM") }
        // Сначала штатное завершение через меню Apple гостевой macOS. Не сохраняем грязный диск.
        try machine.requestStop()
        for _ in 0..<600 {
            if machine.state == .stopped { break }
            try await _Concurrency.Task.sleep(for: .milliseconds(250))
        }
        guard machine.state == .stopped else { throw VirtualMachineConfiguration.error("Завершите работу гостевой macOS, затем повторите сохранение") }
        self.machine = nil
        try Data("{\"schemaVersion\":1}".utf8).write(to: VirtualMachineConfiguration.base.appendingPathComponent("Ready.json"), options: .atomic)
        message = "Базовый образ сохранён. Готовность runner проверяется первым заданием."
    }
}
