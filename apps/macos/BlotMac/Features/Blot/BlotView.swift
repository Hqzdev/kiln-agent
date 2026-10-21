//
//  BlotView.swift
//  BlotMac
//
//  Blot — the pet that lives in Blot. Drawn from agent.pen («18 · Blot»): one body path,
//  two hook-eyes whose notch shows where he looks, a role accessory and the 13 motions in
//  BlotMotion. Body follows the theme (ink on light, paper on dark).
//

import AppKit
import SwiftUI

enum BlotFraming {
    /// Free-standing pet on a 170 × 170 artboard with room for bubbles and badges.
    case stage
    /// Circle avatar: Blot rises from the bottom edge, accessories may be cropped.
    case avatar
}

struct BlotView: View {
    var role: AgentRole = .blot
    var state: BlotState = .idle
    var size: CGFloat = 40
    var replay: Int = 0
    var framing: BlotFraming = .stage
    /// Eyes track the mouse while it is within 240 pt (while resting).
    var followsPointer = false
    /// nil = automatic: lively for a free-standing Blot of 56 pt and up, subtle otherwise.
    var behavior: BlotBehavior? = nil
    /// Clicking him plays a reaction (only where he is not inside another button).
    var tappable = false
    /// Start with «Peek in» the first time he appears.
    var intro = false
    var context: BlotContext = .gallery

    @Environment(AppState.self) private var app
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @State private var started = Date()
    @State private var blinkStarted: Date?
    @State private var finished = false
    @State private var introPlayed = false
    @State private var frame: CGRect = .zero
    @State private var director = BlotDirector()
    @State private var visible = false
    private var active: Bool { scenePhase == .active && visible }
    private var reduced: Bool { systemReduceMotion || app.settings.reduceMotion }

    private var resolvedBehavior: BlotBehavior {
        if reduced { return .none }
        if let behavior { return behavior }
        return framing == .stage && size >= 56 ? .lively : .subtle
    }
    /// The director takes over whenever the agent has nothing to say.
    private var ambient: Bool { state == .idle && resolvedBehavior != .none }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30,
                                paused: !active || reduced || (!ambient && finished && !followsPointer))) { timeline in
            let current = ambient ? director.act : state
            let since = ambient ? director.actStart : started
            let elapsed = max(0, timeline.date.timeIntervalSince(since))
            let effective: BlotState = !ambient && state == .idle && elapsed > 300 ? .sleep : current
            let pose = adjusted(
                BlotMotion.pose(state: effective, elapsed: reduced ? 10 : elapsed,
                                blink: reduced || effective == .sleep ? 1 : blink(at: timeline.date),
                                variant: ambient ? director.variant : 0),
                state: effective)
            BlotDrawing(role: role, pose: pose, framing: framing, elapsed: reduced ? 0 : elapsed)
        }
        .frame(width: size, height: size)
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { value in
            frame = value
            director.frame = value
        }
        .modifier(BlotTap(enabled: tappable && ambient) { director.poke() })
        .onAppear { visible = true }
        .onDisappear { visible = false }
        .accessibilityElement()
        .accessibilityLabel(role == .blot ? "Blot · \(state.title)" : "\(role.title) · \(state.title)")
        .task(id: "\(state.rawValue)-\(replay)-\(reduced)-\(active)") {
            guard active else { return }
            started = Date(); finished = false
            if let duration = state.duration {
                try? await Task.sleep(for: .seconds(duration))
                if !Task.isCancelled { finished = true }
            }
        }
        .task(id: "\(ambient)-\(resolvedBehavior)-\(active)") {
            guard ambient && active else { return }
            director.framing = framing
            let playIntro = intro && !introPlayed
            introPlayed = true
            await director.run(resolvedBehavior, intro: playIntro)
        }
        .task(id: "\(reduced)-\(active)") {
            guard !reduced && active else { blinkStarted = nil; return }
            while !Task.isCancelled {
                do { try await Task.sleep(for: .seconds(Double.random(in: 3...5))) } catch { return }
                blinkStarted = Date()
            }
        }
        .onChange(of: app.blotStimulus) { _, stimulus in
            if active && ambient && resolvedBehavior == .lively && stimulus.context == context { director.stimulate(stimulus.kind) }
        }
    }

    /// While resting, a nearby pointer pulls his gaze.
    private func adjusted(_ pose: BlotPose, state: BlotState) -> BlotPose {
        guard followsPointer, !reduced, state == .idle || state == .planning,
              let window = NSApp.keyWindow, let content = window.contentView else { return pose }
        let mouse = window.mouseLocationOutsideOfEventStream
        let pointer = CGPoint(x: mouse.x, y: content.bounds.height - mouse.y)
        let eye = BlotDrawing.eyeCenter(in: frame, framing: framing)
        let dx = pointer.x - eye.x, dy = pointer.y - eye.y
        let distance = hypot(dx, dy)
        guard distance < 240 else { return pose }
        var copy = pose
        if distance < 8 { copy.gazeX = 0; copy.gazeY = 0 } else { copy.gazeX = dx / distance; copy.gazeY = dy / distance }
        return copy
    }

    private func blink(at date: Date) -> Double {
        guard let start = blinkStarted else { return 1 }
        let elapsed = date.timeIntervalSince(start)
        guard elapsed >= 0 && elapsed < 0.24 else { return 1 }
        return abs(elapsed - 0.12) / 0.12
    }
}

/// Adds a click reaction only where Blot is not part of another control.
private struct BlotTap: ViewModifier {
    let enabled: Bool
    let action: () -> Void
    func body(content: Content) -> some View {
        if enabled { content.contentShape(Rectangle()).onTapGesture(perform: action) } else { content }
    }
}

/// Static Blot for a single pose — also used by `FaceAvatar`.
struct BlotDrawing: View {
    let role: AgentRole
    var pose = BlotPose()
    var framing: BlotFraming = .stage
    var elapsed: Double = 0

    static let stageUnits: CGFloat = 170
    static let stageOrigin = CGPoint(x: 25, y: 58)

    /// Eye midpoint in the coordinate space of `frame`, used for pointer tracking.
    static func eyeCenter(in frame: CGRect, framing: BlotFraming) -> CGPoint {
        let unit = CGPoint(x: 77, y: 33.5)
        switch framing {
        case .stage:
            let s = frame.width / stageUnits
            return CGPoint(x: frame.minX + (stageOrigin.x + unit.x) * s, y: frame.minY + (stageOrigin.y + unit.y) * s)
        case .avatar:
            let s = frame.width * 0.86 / 120
            return CGPoint(x: frame.minX + (frame.width - 120 * s) / 2 + unit.x * s, y: frame.minY + frame.height * 0.3 + unit.y * s)
        }
    }

    var body: some View {
        Canvas { context, size in
            let bodyColor = K.text
            let eyeColor = K.bg
            switch framing {
            case .stage:
                let s = size.width / Self.stageUnits
                context.scaleBy(x: s, y: s)
                let lift = min(1, abs(pose.y) / 30)
                context.fill(Path(ellipseIn: CGRect(x: Self.stageOrigin.x + 18 - 8 * lift, y: 160, width: 84 + 16 * lift, height: 6)),
                             with: .color(K.text.opacity(0.08 * (1 - 0.6 * lift))))
                context.translateBy(x: Self.stageOrigin.x, y: Self.stageOrigin.y)
            case .avatar:
                let circle = Path(ellipseIn: CGRect(origin: .zero, size: size))
                context.fill(circle, with: .color(K.surface2))
                context.clip(to: circle)
                let s = size.width * 0.86 / 120
                context.translateBy(x: (size.width - 120 * s) / 2, y: size.height * 0.3)
                context.scaleBy(x: s, y: s)
            }

            context.translateBy(x: pose.x, y: pose.y)
            context.translateBy(x: 60, y: 100)
            context.rotate(by: .degrees(pose.tilt))
            context.scaleBy(x: pose.scaleX, y: pose.scaleY)
            context.translateBy(x: -60, y: -100)

            context.fill(BlotGeometry.body, with: .color(bodyColor))
            if pose.ember > 0 {
                context.fill(Path(ellipseIn: CGRect(x: 18, y: 57, width: 10, height: 10)), with: .color(K.ember.opacity(pose.ember)))
            }
            for index in 0..<2 { drawEye(index, in: &context, body: bodyColor, eye: eyeColor) }
            for shape in BlotGeometry.accessories[role] ?? [] { shape.draw(in: &context) }
            if framing == .stage { drawEffects(in: &context, eye: eyeColor) }
        }
    }

    private func drawEye(_ index: Int, in context: inout GraphicsContext, body: Color, eye: Color) {
        let x0 = BlotGeometry.eyeX[index] + pose.gazeX * 1.5
        let y0 = BlotGeometry.eyeY + pose.gazeY * 1.5
        let open = index == 0 ? pose.openL : pose.openR
        let happy = index == 0 ? pose.happyL : pose.happyR
        let stroke = StrokeStyle(lineWidth: 4.2, lineCap: .round, lineJoin: .round)

        if pose.cross {
            var path = Path()
            path.move(to: CGPoint(x: x0 + 1, y: y0 + 4)); path.addLine(to: CGPoint(x: x0 + 15, y: y0 + 18))
            path.move(to: CGPoint(x: x0 + 15, y: y0 + 4)); path.addLine(to: CGPoint(x: x0 + 1, y: y0 + 18))
            context.stroke(path, with: .color(eye), style: stroke)
            return
        }
        if happy {
            var path = Path()
            path.move(to: CGPoint(x: x0, y: y0 + 15))
            path.addLine(to: CGPoint(x: x0 + 8, y: y0 + 6))
            path.addLine(to: CGPoint(x: x0 + 16, y: y0 + 15))
            context.stroke(path, with: .color(eye), style: stroke)
            return
        }
        if pose.sad {
            let inner: CGFloat = index == 0 ? 8 : 14, outer: CGFloat = index == 0 ? 14 : 8
            var path = Path()
            path.move(to: CGPoint(x: x0, y: y0 + inner))
            path.addLine(to: CGPoint(x: x0 + 16, y: y0 + outer))
            path.addLine(to: CGPoint(x: x0 + 16, y: y0 + 19))
            path.addQuadCurve(to: CGPoint(x: x0 + 14, y: y0 + 21), control: CGPoint(x: x0 + 16, y: y0 + 21))
            path.addLine(to: CGPoint(x: x0 + 2, y: y0 + 21))
            path.addQuadCurve(to: CGPoint(x: x0, y: y0 + 19), control: CGPoint(x: x0, y: y0 + 21))
            path.closeSubpath()
            context.fill(path, with: .color(eye))
            return
        }
        if open < 0.15 {
            context.fill(Path(roundedRect: CGRect(x: x0, y: y0 + 14, width: 16, height: 4), cornerRadius: 2), with: .color(eye))
            return
        }
        let grow = pose.big
        let width = 16 + 4 * grow, height = 21 + 5 * grow
        let visible = max(4, height * open)
        let rect = CGRect(x: x0 - 2 * grow, y: y0 - 3 * grow + height - visible, width: width, height: visible)
        context.fill(Path(roundedRect: rect, cornerRadius: min(2.5 + grow * 0.5, visible / 2)), with: .color(eye))

        guard open > 0.45, grow < 0.5 else { return }
        let gx = pose.gazeX, gy = pose.gazeY
        guard max(abs(gx), abs(gy)) >= 0.3 else { return }
        let notchHeight = min(7, rect.height * 0.4)
        let notch: CGRect
        if abs(gx) >= abs(gy) {
            notch = CGRect(x: gx > 0 ? rect.minX : rect.maxX - 7, y: rect.midY - notchHeight / 2, width: 7, height: notchHeight)
        } else {
            notch = CGRect(x: rect.midX - 3.5, y: gy < 0 ? rect.maxY - 7 : rect.minY, width: 7, height: 7)
        }
        context.fill(Path(notch), with: .color(body))
    }

    private func drawEffects(in context: inout GraphicsContext, eye: Color) {
        let amber = Color(hex: 0xF6B84B)
        if pose.sparks {
            for (cx, cy, r) in [(-8.0, 6.0, 9.0), (130.0, 22.0, 7.0)] {
                var star = Path()
                star.move(to: CGPoint(x: cx, y: cy - r))
                star.addQuadCurve(to: CGPoint(x: cx + r, y: cy), control: CGPoint(x: cx, y: cy))
                star.addQuadCurve(to: CGPoint(x: cx, y: cy + r), control: CGPoint(x: cx, y: cy))
                star.addQuadCurve(to: CGPoint(x: cx - r, y: cy), control: CGPoint(x: cx, y: cy))
                star.addQuadCurve(to: CGPoint(x: cx, y: cy - r), control: CGPoint(x: cx, y: cy))
                context.fill(star, with: .color(amber))
            }
        }
        if pose.bang {
            context.fill(Path(ellipseIn: CGRect(x: 118, y: -14, width: 24, height: 24)), with: .color(amber))
            var mark = Path()
            mark.move(to: CGPoint(x: 130, y: -8)); mark.addLine(to: CGPoint(x: 130, y: 0))
            mark.move(to: CGPoint(x: 130, y: 5)); mark.addLine(to: CGPoint(x: 130, y: 5.5))
            context.stroke(mark, with: .color(Color(hex: 0x141414)), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        }
        if pose.dots > 0 {
            let ink = K.text
            context.fill(Path(ellipseIn: CGRect(x: 114, y: 0, width: 6, height: 6)), with: .color(ink))
            if pose.dots > 1 { context.fill(Path(ellipseIn: CGRect(x: 121, y: -10, width: 8, height: 8)), with: .color(ink)) }
            if pose.dots > 2 {
                context.fill(Path(roundedRect: CGRect(x: 118, y: -32, width: 30, height: 18), cornerRadius: 8), with: .color(ink))
                for i in 0..<3 {
                    context.fill(Path(ellipseIn: CGRect(x: 124 + Double(i) * 7, y: -24.5, width: 3, height: 3)), with: .color(eye))
                }
            }
        }
        if pose.sweat {
            context.fill(SVGPath.parse("M24 14C20 20 20 24 24 24C28 24 28 20 24 14Z"), with: .color(Color(hex: 0x6EA8FE)))
        }
        if pose.asleep {
            for index in 0..<3 {
                let phase = (elapsed / 3 + Double(index) / 3).truncatingRemainder(dividingBy: 1)
                var copy = context
                copy.opacity = 1 - phase
                copy.draw(Text("z").font(.system(size: 12 + Double(index) * 3, weight: .semibold)).foregroundColor(K.text2),
                          at: CGPoint(x: 124 + Double(index) * 8, y: 8 - phase * 24))
            }
        }
    }
}
