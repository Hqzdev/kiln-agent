//
//  Composer.swift
//  BlotMac
//
//  «Composer» block: optional context bar, multi-line input and a toolbar with
//  approval mode, model and send.
//

import SwiftUI

struct Composer: View {
    @Environment(AppState.self) private var app
    @Binding var text: String
    var placeholder: String
    var context: ComposerContext? = nil
    var petContext: BlotContext? = nil
    var approvalModes: [String] = ["Ask before running", "Auto-approve in workspace", "Read-only"]
    var models: [String] = ["Blot 1 · High", "Blot 1 · Medium", "Blot 1 Mini"]
    var canSend = true
    var status: String?
    var statusTone: InlineFeedback.Tone = .information
    var onStop: (() -> Void)?
    var onSend: () -> Void

    @State private var approval = ""
    @State private var model = ""
    @State private var reasoningEffort: ReasoningEffort = .high
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: KSpace.sm) {
            if let status { InlineFeedback(text: status, tone: statusTone).padding(.horizontal, KSpace.md) }
            VStack(spacing: -K.composerContextOverlap) {
                if let context { ComposerContextBar(context: context).padding(.horizontal, 13) }
                input
            }
        }
        .onChange(of: text) { _, _ in
            if !text.isEmpty, let petContext { app.pokeBlot(.typing, context: petContext) }
        }
        .overlay(alignment: .topTrailing) {
            if let petContext { ComposerBlot(context: petContext).offset(x: -24, y: -43) }
        }
    }

    private var input: some View {
        VStack(spacing: 0) {
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(K.text3), axis: .vertical)
                .textFieldStyle(.plain)
                .font(KFont.body())
                .foregroundStyle(K.text)
                .lineLimit(1...8)
                .lineSpacing(4)
                .focused($focused)
                .accessibilityLabel("Message")
                .accessibilityHint(canSend ? "Press Return to send" : status ?? "Sending is unavailable")
                .onSubmit(send)
                .frame(minHeight: 36, alignment: .topLeading)
                .padding(EdgeInsets(top: 14, leading: 12, bottom: 0, trailing: 16))

            ViewThatFits(in: .horizontal) {
                toolbar(compact: false)
                toolbar(compact: true)
            }
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 12, trailing: 8))

        }
        .frame(minHeight: K.composerHeight, alignment: .top)
        .background(RoundedRectangle(cornerRadius: K.composerRadius, style: .continuous).fill(K.composer))
        .overlay(RoundedRectangle(cornerRadius: K.composerRadius, style: .continuous)
            .strokeBorder(focused ? K.focus : K.border, lineWidth: focused ? 2 : 1))
        .contentShape(Rectangle())
        .onTapGesture { focused = true }
    }

    private func toolbar(compact: Bool) -> some View {
        HStack(spacing: 4) {
            IconButton(icon: "plus", help: "Attachments are unavailable in this local preview").disabled(true)
            if !approvalModes.isEmpty {
                MenuChip(icon: "checkmark.shield", label: compact ? "Approval" : currentApproval) {
                    KMenuItem.choices(approvalModes, selected: currentApproval) { approval = $0 }
                }
            }
            Spacer(minLength: 0)
            ModelPicker(options: ModelOption.options(from: models), selectedModel: $model,
                        effort: $reasoningEffort, compact: compact)
                .fixedSize()
            if let onStop {
                IconButton(icon: "stop", help: "Stop · Esc", action: onStop)
            }
            SendButton(enabled: canSend && !trimmed.isEmpty, size: 28, action: send).padding(.leading, 4)
        }
    }

    private var trimmed: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var currentApproval: String { approval.isEmpty ? (approvalModes.first ?? "") : approval }

    private func send() {
        guard canSend, !trimmed.isEmpty else { return }
        onSend()
    }
}
