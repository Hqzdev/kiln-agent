//
//  LoginView.swift
//  BlotMac
//
//  Auth flow from agent.pen: «09 · Sign up», «10 · Log in», «11 · Verify email».
//  360 pt column centred in the window, footer links at the bottom.
//

import SwiftUI

@MainActor
struct LoginView: View {
    @Environment(AppState.self) private var state
    @State private var model: LoginViewModel
    @State private var showSMTP = false

    init(model: LoginViewModel? = nil) {
        _model = State(initialValue: model ?? LoginViewModel(lastEmail: SessionStore.lastEmail))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title bar: the system draws the traffic lights here.
            Color.clear.frame(height: K.shellToolbarHeight)

            GeometryReader { proxy in
                ScrollView {
                    Group {
                        switch model.screen {
                        case .signUp: SignUpForm(model: model)
                        case .logIn: LogInForm(model: model)
                        case .verify: VerifyEmailForm(model: model)
                        case .reset: ResetPasswordForm(model: model)
                        }
                    }
                    .frame(width: 360)
                    .padding(.bottom, 40)
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                    .transition(.opacity.combined(with: .offset(y: 8)))
                    .id(model.screen)
                }
                .scrollIndicators(.never)
            }

            Button("Configure email delivery on this Mac") { showSMTP = true }.font(KFont.body()).padding(.bottom, 12)
            AuthFooter()
        }
        .background(K.bg)
        .ignoresSafeArea()
        .sheet(isPresented: $showSMTP) { SMTPSetupView() }
        .onChange(of: model.signedInUser) { _, user in
            guard let user else { return }
            state.signIn(user, remember: model.staySignedIn)
        }
    }
}

// MARK: - Screens

private struct SignUpForm: View {
    @Bindable var model: LoginViewModel

    var body: some View {
        VStack(spacing: 24) {
            AuthHeading(
                title: "Create your Blot account",
                subtitle: "An agent that plans, edits and tests code right on your Mac."
            )

            VStack(spacing: 12) {
                AuthField(label: "Email", icon: "envelope", placeholder: "you@example.com", text: $model.email,
                          autofocus: true, onSubmit: { model.sendCode() },
                          error: model.error == AuthError.invalidEmail.errorDescription ? model.error : nil)
                AuthField(label: "Password", icon: "lock", placeholder: "At least 12 characters", text: $model.password,
                          secure: true, onSubmit: { model.sendCode() })
                AuthErrorText(message: model.error)
                PrimaryAuthButton(title: "Continue with email", loading: model.isLoading,
                                  action: { model.sendCode() })
            }

            Text("By continuing you agree to the Terms of Service and Privacy Policy. We'll send a 6-digit code to confirm your email.")
                .font(KFont.body())
                .foregroundStyle(K.text3)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            SwitchPrompt(question: "Already have an account?", link: "Log in") { model.show(.logIn) }
        }
    }
}

private struct LogInForm: View {
    @Bindable var model: LoginViewModel

    var body: some View {
        VStack(spacing: 24) {
            AuthHeading(
                title: "Welcome back",
                subtitle: "Log in to pick up your tasks where Blot left off."
            )

            VStack(spacing: 12) {
                AuthField(label: "Email", icon: "envelope", placeholder: "you@example.com", text: $model.email,
                          autofocus: model.email.isEmpty, onSubmit: { model.logIn() },
                          error: model.error == AuthError.invalidEmail.errorDescription ? model.error : nil)
                AuthField(label: "Password", icon: "lock", placeholder: "Password", text: $model.password,
                          secure: true, autofocus: !model.email.isEmpty, onSubmit: { model.logIn() },
                          trailingLink: ("Forgot password?", { model.requestPasswordReset() }),
                          error: model.error == AuthError.emptyPassword.errorDescription || model.error == AuthError.wrongCredentials.errorDescription ? model.error : nil)

                HStack(spacing: 10) {
                    KToggle(isOn: $model.staySignedIn)
                    Text("Stay signed in on this Mac")
                        .font(KFont.body())
                        .foregroundStyle(K.text2)
                        .onTapGesture { withAnimation(.snappy(duration: 0.18)) { model.staySignedIn.toggle() } }
                    Spacer()
                }
                .padding(.vertical, 2)

                AuthErrorText(message: model.error)
                PrimaryAuthButton(title: "Log in", loading: model.isLoading,
                                  action: { model.logIn() })
            }


            SwitchPrompt(question: "New to Blot?", link: "Create an account") { model.show(.signUp) }
        }
    }
}

private struct VerifyEmailForm: View {
    @Bindable var model: LoginViewModel

    var body: some View {
        VStack(spacing: 24) {
            AuthHeading(
                title: "Check your email",
                subtitle: "We sent a 6-digit code to \(model.email.isEmpty ? "your email" : model.email). It expires in 10 minutes."
            )

            VStack(spacing: 12) {
                CodeInput(code: $model.code, disabled: model.isLoading, invalid: model.error != nil)
                AuthErrorText(message: model.error)
            }

            PrimaryAuthButton(title: "Verify and continue", loading: model.isLoading,
                              enabled: model.canSubmitCode, action: { model.verify() })

            VStack(spacing: 8) {
                TextLink(
                    title: model.resendLabel,
                    color: model.resendSeconds > 0 ? K.text3 : K.text2,
                    action: { model.resendCode() }
                )
                .disabled(model.resendSeconds > 0)
                TextLink(title: "Use a different email", color: K.text, weight: .medium, action: { model.useDifferentEmail() })
            }
        }
    }
}

// MARK: - Pieces

/// The Blot arch: 56 × 64, top radius 28, 7 pt inner stroke, ember slot as the mouth.
struct BlotMark: View {
    var height: CGFloat = 64
    var body: some View {
        BlotDrawing(role: .blot)
            .frame(width: height, height: height)
            .accessibilityLabel("Blot")
    }
}

private struct AuthHeading: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 24) {
            BlotMark()
            VStack(spacing: 8) {
                Text(title)
                    .font(KFont.ui(28, .semibold))
                    .kerning(-0.5)
                    .foregroundStyle(K.text)
                Text(subtitle)
                    .font(KFont.body())
                    .foregroundStyle(K.text2)
                    .lineSpacing(6)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct ResetPasswordForm: View {
    @Bindable var model: LoginViewModel
    var body: some View {
        VStack(spacing: 20) {
            AuthHeading(title: "Reset password", subtitle: "Enter the code from your email and a new password.")
            CodeInput(code: $model.code, disabled: model.isLoading, invalid: model.error != nil)
            AuthField(label: "New password", icon: "lock", placeholder: "At least 12 characters", text: $model.password,
                      secure: true, onSubmit: { model.resetPassword() })
            AuthErrorText(message: model.error)
            PrimaryAuthButton(title: "Change password", loading: model.isLoading,
                              enabled: model.code.count == 6, action: { model.resetPassword() })
            TextLink(title: "Back to login", action: { model.show(.logIn) })
        }
    }
}

private struct AuthField: View {
    let label: String
    let icon: String
    let placeholder: String
    @Binding var text: String
    var secure = false
    var autofocus = false
    var onSubmit: () -> Void = {}
    var trailingLink: (title: String, action: () -> Void)?
    var error: String?

    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(KFont.body(.medium))
                    .foregroundStyle(K.text2)
                Spacer()
                if let trailingLink {
                    TextLink(title: trailingLink.title, size: 12, action: trailingLink.action)
                }
            }

            HStack(spacing: 10) {
                KIcon(icon, size: 14, color: K.text3)
                Group {
                    if secure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .textContentType(.username)
                    }
                }
                .textFieldStyle(.plain)
                .font(KFont.body())
                .foregroundStyle(K.text)
                .focused($focused)
                .accessibilityLabel(label)
                .accessibilityHint(error ?? "")
                .onSubmit(onSubmit)
            }
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(RoundedRectangle(cornerRadius: K.rMd, style: .continuous).fill(K.bg))
            .overlay(
                RoundedRectangle(cornerRadius: K.rMd, style: .continuous)
                    .strokeBorder(error != nil ? K.danger : focused ? K.focus : K.borderStrong, lineWidth: focused ? 2 : 1)
            )
            .contentShape(Rectangle())
            .onTapGesture { focused = true }
        }
        .onAppear {
            if autofocus { focused = true }
        }
    }
}

/// Six digit boxes with a dash after the third, backed by one hidden text field.
private struct CodeInput: View {
    @Binding var code: String
    var disabled = false
    var invalid = false
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            TextField("", text: $code)
                .textFieldStyle(.plain)
                .focused($focused)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .disabled(disabled)
                .accessibilityLabel("Verification code")

            HStack(spacing: 8) {
                ForEach(0..<LoginViewModel.codeLength, id: \.self) { index in
                    if index == 3 {
                        Text("–")
                            .font(KFont.ui(16))
                            .foregroundStyle(K.text3)
                    }
                    digitBox(index)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { focused = true }
        }
        .onAppear { focused = true }
    }

    private func digitBox(_ index: Int) -> some View {
        let digits = Array(code)
        let active = focused && !disabled && index == min(digits.count, LoginViewModel.codeLength - 1)
        return ZStack {
            if index < digits.count {
                Text(String(digits[index]))
                    .font(KFont.ui(22, .medium))
                    .foregroundStyle(K.text)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            } else if active {
                BlinkingCaret()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(RoundedRectangle(cornerRadius: K.rMd, style: .continuous).fill(K.bg))
        .overlay(
            RoundedRectangle(cornerRadius: K.rMd, style: .continuous)
                .strokeBorder(invalid ? K.danger : active ? K.focus : K.borderStrong, lineWidth: active ? 2 : 1)
        )
        .animation(.snappy(duration: 0.15), value: code)
    }
}

private struct BlinkingCaret: View {
    @Environment(\.blotReduceMotion) private var reducedMotion
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.53, paused: reducedMotion)) { context in
            let visible = reducedMotion || Int(context.date.timeIntervalSinceReferenceDate / 0.53) % 2 == 0
            Rectangle()
                .fill(K.text2)
                .frame(width: 1.5, height: 22)
                .opacity(visible ? 1 : 0)
        }
    }
}

private struct PrimaryAuthButton: View {
    let title: String
    var loading = false
    var enabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title).opacity(loading ? 0 : 1)
                if loading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(K.onInverse)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(KButtonStyle(kind: .primary, height: 40))
        .kFocusRing()
        .accessibilityLabel(loading ? "\(title), waiting" : title)
        .disabled(!enabled || loading)
    }
}

private struct AuthErrorText: View {
    let message: String?

    var body: some View {
        if let message {
            HStack(alignment: .top, spacing: 6) {
                KIcon("exclamationmark.circle", size: 13, color: K.danger)
                Text(message)
                    .font(KFont.body())
                    .foregroundStyle(K.danger)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .transition(.opacity)
        }
    }
}

private struct SwitchPrompt: View {
    let question: String
    let link: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(question)
                .font(KFont.body())
                .foregroundStyle(K.text2)
            TextLink(title: link, color: K.text, weight: .medium, action: action)
        }
    }
}

private struct TextLink: View {
    let title: String
    var color: Color = K.text2
    var weight: KFont.Weight = .regular
    var size: CGFloat = 13
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(KFont.ui(size, weight))
                .foregroundStyle(color)
                .underline(hovering)
        }
        .buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm)
        .onHover { hovering = $0 }
    }
}

private struct AuthFooter: View {
    var body: some View {
        HStack(spacing: 20) {
            ForEach(["Terms", "Privacy", "Status", "Help"], id: \.self) { title in
                TextLink(title: title, color: K.text3, size: 12) {}
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
    }
}
