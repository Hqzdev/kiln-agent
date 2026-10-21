import SwiftUI

struct AssistantsLibraryView: View {
    @Environment(AppState.self) private var app
    @State private var creating = false
    @State private var editing: AssistantProfile?
    var body: some View {
        PageContent {
            VStack(alignment: .leading, spacing: 0) {
                WorkspacePageHeader(title: "GPTs", detail: "Create assistants with instructions for the way you work.") {
                    KButton(title: "Create GPT", icon: "plus") { creating = true }
                }
                if app.workspaceLibrary.assistants.isEmpty {
                    WorkspaceEmptyView(icon: "cube", title: "Your own assistants",
                                       detail: "Give an assistant a name and instructions, then start a conversation.")
                } else {
                    ForEach(app.workspaceLibrary.assistants) { assistant in
                        HStack(alignment: .top, spacing: 14) {
                            KIcon("cube", size: 24, color: K.text2).padding(.top, 2)
                            VStack(alignment: .leading, spacing: 8) {
                                Text(assistant.name).font(KFont.ui(16, .medium)).foregroundStyle(K.text)
                                Text(assistant.instructions).font(KFont.body()).foregroundStyle(K.text2).lineLimit(3)
                                HStack {
                                    KButton(title: "Start chat", icon: "message-square", kind: .ghost) {
                                        app.openAssistantChat(assistant)
                                    }
                                    KButton(title: "Edit", kind: .ghost) { editing = assistant }
                                }
                            }.frame(maxWidth: .infinity, alignment: .leading)
                            IconButton(icon: "trash-2", help: "Remove \(assistant.name)") {
                                app.workspaceLibrary.removeAssistant(assistant.id)
                            }
                        }.padding(.vertical, 18)
                        HDivider()
                    }
                }
            }
        }
        .sheet(isPresented: $creating) { AssistantEditorView { app.workspaceLibrary.saveAssistant($0) } }
        .sheet(item: $editing) { assistant in
            AssistantEditorView(assistant: assistant) { app.workspaceLibrary.saveAssistant($0) }
        }
    }
}

private struct AssistantEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let assistant: AssistantProfile?
    let save: (AssistantProfile) -> Void
    @State private var name: String
    @State private var instructions: String
    init(assistant: AssistantProfile? = nil, save: @escaping (AssistantProfile) -> Void) {
        self.assistant = assistant
        self.save = save
        _name = State(initialValue: assistant?.name ?? "")
        _instructions = State(initialValue: assistant?.instructions ?? "")
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(assistant == nil ? "Create GPT" : "Edit GPT").font(KFont.ui(20, .semibold))
            SettingsTextField(label: "Name", text: $name)
            Text("Instructions").font(KFont.body(.medium))
            TextEditor(text: $instructions).font(KFont.body()).scrollContentBackground(.hidden)
                .padding(10).frame(height: 220).kCard(fill: K.surface)
                .accessibilityLabel("Assistant instructions")
            HStack {
                Spacer()
                KButton(title: "Cancel") { dismiss() }.keyboardShortcut(.cancelAction)
                KButton(title: "Save", kind: .primary) {
                    save(AssistantProfile(id: assistant?.id ?? UUID(), name: trimmedName, instructions: trimmedInstructions))
                    dismiss()
                }.disabled(trimmedName.isEmpty || trimmedInstructions.isEmpty).keyboardShortcut(.defaultAction)
            }
        }.padding(24).frame(width: 560).background(K.bg).foregroundStyle(K.text)
    }
    private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var trimmedInstructions: String { instructions.trimmingCharacters(in: .whitespacesAndNewlines) }
}
