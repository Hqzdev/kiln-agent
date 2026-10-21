import SwiftUI

/// Model and reasoning controls shared by the chat composers.
struct ModelPicker: View {
    @Environment(AppState.self) private var app
    let options: [ModelOption]
    @Binding var selectedModel: String
    @Binding var effort: ReasoningEffort
    var compact = false
    @State private var presented = false
    private var current: String { selectedModel.isEmpty ? options.first?.name ?? "Default" : selectedModel }
    private var reasoningAvailable: Bool { options.first { $0.name == current }?.supportsReasoning ?? true }

    var body: some View {
        Button { presented.toggle() } label: {
            Chip(icon: "sparkle", label: compact ? "Model" : (reasoningAvailable ? "\(current) · \(effort.rawValue)" : current))
        }
        .buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm)
        .accessibilityLabel("Select model")
        .accessibilityValue(current)
        .onChange(of: app.paletteVisible) { _, visible in if visible { presented = false } }
        .popover(isPresented: $presented, arrowEdge: .bottom) {
            ModelPickerPanel(options: options, selectedModel: $selectedModel, effort: $effort,
                             defaultModel: options.first?.name ?? "Default")
                .presentationBackground(K.surface)
                .onExitCommand { presented = false }
        }
    }
}

struct ModelPickerPanel: View {
    let options: [ModelOption]
    @Binding var selectedModel: String
    @Binding var effort: ReasoningEffort
    let defaultModel: String
    @State private var choosingModel = false
    @FocusState private var panelFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var current: String { selectedModel.isEmpty ? defaultModel : selectedModel }
    private var reasoningAvailable: Bool { options.first { $0.name == current }?.supportsReasoning ?? true }

    init(options: [ModelOption], selectedModel: Binding<String>, effort: Binding<ReasoningEffort>,
         defaultModel: String, choosingModel: Bool = false) {
        self.options = options
        _selectedModel = selectedModel
        _effort = effort
        self.defaultModel = defaultModel
        _choosingModel = State(initialValue: choosingModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if choosingModel {
                HStack {
                    Button { changePage(false) } label: {
                        HStack(spacing: 4) {
                            KIcon("chevron-left", size: 12, color: K.text2)
                            Text("Select model").font(KFont.caption(.medium)).foregroundStyle(K.text2)
                        }
                    }.buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm)
                    Spacer()
                }.padding(.horizontal, 7).padding(.vertical, 4)
                ScrollView {
                    VStack(spacing: 2) {
                        modelRow("Default", detail: "Recommended model", selected: selectedModel.isEmpty) {
                            selectedModel = ""; changePage(false)
                        }
                        HDivider().padding(.vertical, 4).padding(.horizontal, 10)
                        ForEach(options) { option in
                            modelRow(option.name, selected: selectedModel == option.name) {
                                selectedModel = option.name; changePage(false)
                            }
                        }
                    }
                }.frame(maxHeight: 200)
            } else {
                HStack {
                    KIcon("zap", size: 13, color: K.text3)
                    Spacer()
                    Text(reasoningAvailable ? effort.rawValue : "Fast")
                        .font(KFont.body(.medium)).foregroundStyle(K.ember)
                    Spacer()
                    Button { selectedModel = ""; effort = .high } label: {
                        KIcon("rotate-ccw", size: 15, color: K.text2)
                            .frame(width: 19, height: 19).kHover(radius: 4)
                    }.buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm).help("Reset model and reasoning effort")
                }.padding(.horizontal, 7)
                Button { changePage(true) } label: {
                    HStack(spacing: 5) {
                        Text(current).font(KFont.body())
                        KIcon("chevron-right", size: 10, color: K.text2)
                    }.foregroundStyle(K.text2).frame(maxWidth: .infinity).padding(.vertical, 3)
                        .kHover(radius: K.rMd)
                }.buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm).accessibilityLabel("Choose model")
                if reasoningAvailable {
                    ReasoningSlider(effort: $effort)
                    Text("More effort gives the model more time to reason.")
                        .font(KFont.caption()).foregroundStyle(K.text3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 3)
                } else {
                    Text("A fast model for small edits.").font(KFont.caption()).foregroundStyle(K.text3)
                        .frame(maxWidth: .infinity).padding(.vertical, 7)
                }
            }
        }
        .padding(.horizontal, 8).padding(.vertical, 10).frame(width: 213)
        .background(K.surface)
        .focusable()
        .focusEffectDisabled()
        .focused($panelFocused)
        .onAppear { panelFocused = true }
    }

    private func modelRow(_ name: String, detail: String? = nil, selected: Bool,
                          action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(name).font(KFont.body(selected ? .medium : .regular)).foregroundStyle(K.text)
                    if let detail { Text(detail).font(KFont.caption()).foregroundStyle(K.text3) }
                }
                Spacer()
                if selected { KIcon("check", size: 14, color: K.text2) }
            }.padding(.horizontal, 7).padding(.vertical, 7)
                .contentShape(Rectangle()).kHover(radius: K.rMd, active: selected)
        }.buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm).accessibilityAddTraits(selected ? .isSelected : [])
    }
    private func changePage(_ value: Bool) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.16)) { choosingModel = value }
    }
}
