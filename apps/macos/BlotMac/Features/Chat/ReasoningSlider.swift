import SwiftUI

struct ReasoningSlider: View {
    @Binding var effort: ReasoningEffort
    @FocusState private var focused: Bool

    var body: some View {
        GeometryReader { geometry in
            let inset: CGFloat = 13
            let width = max(1, geometry.size.width - inset * 2)
            let progress = effort.index / Double(ReasoningEffort.allCases.count - 1)

            ZStack(alignment: .topLeading) {
                Capsule().fill(K.text3.opacity(0.45))
                    .frame(width: width, height: 4)
                    .offset(x: inset, y: 12)
                Capsule().fill(K.ember)
                    .frame(width: width * progress, height: 4)
                    .offset(x: inset, y: 12)
                ForEach(ReasoningEffort.allCases) { option in
                    let x = inset + width * option.index / Double(ReasoningEffort.allCases.count - 1)
                    Circle().fill(K.text3.opacity(0.6))
                        .frame(width: 2, height: 2).offset(x: x - 1, y: 19)
                    Circle().fill(option == effort ? K.ember : K.text3.opacity(0.6))
                        .frame(width: 3, height: 3).offset(x: x - 1.5, y: 31)
                }
                Capsule().fill(.white)
                    .frame(width: 10, height: 18)
                    .offset(x: inset + width * progress - 5, y: 5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                focused = true
                effort = ReasoningEffort(index: Double((value.location.x - inset) / width)
                                         * Double(ReasoningEffort.allCases.count - 1))
            })
        }
        .frame(height: 44)
        .background(K.surface2, in: RoundedRectangle(cornerRadius: 11))
        .overlay(RoundedRectangle(cornerRadius: 11)
            .strokeBorder(focused ? K.ember.opacity(0.6) : K.border, lineWidth: 1))
        .focusable()
        .focusEffectDisabled()
        .focused($focused)
        .onKeyPress(.leftArrow) { adjust(by: -1); return .handled }
        .onKeyPress(.rightArrow) { adjust(by: 1); return .handled }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Reasoning effort")
        .accessibilityValue(effort.rawValue)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: adjust(by: 1)
            case .decrement: adjust(by: -1)
            @unknown default: break
            }
        }
    }

    private func adjust(by step: Double) {
        effort = ReasoningEffort(index: effort.index + step)
    }
}
