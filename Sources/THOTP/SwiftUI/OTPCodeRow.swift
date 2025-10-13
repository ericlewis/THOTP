import SwiftUI

/// A SwiftUI view that displays an OTP password with animated countdown for TOTP.
///
/// This view shows the issuer name, account name, current OTP code, and for timer-based
/// passwords, displays an animated countdown and progress bar.
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, *)
public struct OTPCodeRow: View {
    let password: Password
    @State private var currentCode: String = "------"
    @State private var timeRemaining: TimeInterval = 0
    @State private var progress: Double = 0
    @State private var showCopiedToast = false
    @State private var isTapped = false

    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    public init(password: Password) {
        self.password = password
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(password.issuer ?? "Unknown")
                        .font(.headline)
                    Text(password.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isTimerBased {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(currentCode)
                            .font(.system(.title2, design: .monospaced).weight(.medium))
                            .monospacedDigit()
                            .foregroundStyle(textColor)
                            .opacity(flashOpacity)
                            .scaleEffect(scaleEffect * (isTapped ? 0.95 : 1.0))
                            .shadow(color: glowColor.opacity(glowIntensity * 0.35), radius: 30 - (glowIntensity * 25))
                            .shadow(color: glowColor.opacity(glowIntensity * 0.2), radius: 50 - (glowIntensity * 40))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                copyToClipboard(currentCode)
                            }

                        Text("\(Int(timeRemaining))s")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text(currentCode)
                        .font(.system(.title2, design: .monospaced))
                        .fontWeight(.medium)
                        .scaleEffect(isTapped ? 0.95 : 1.0)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            copyToClipboard(currentCode)
                        }
                }
            }

            if isTimerBased {
                ProgressView(value: progress)
                    .tint(progressColor)
                    .animation(.linear(duration: 0.1), value: progress)
            }
        }
        .padding(.vertical, 8)
        .onReceive(timer) { _ in
            updatePassword()
        }
        .onAppear {
            updatePassword()
        }
        .overlay(alignment: .top) {
            if showCopiedToast {
                Text("Copied to clipboard")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.thinMaterial, in: Capsule())
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .offset(y: -8)
            }
        }
    }

    private var isTimerBased: Bool {
        if case .timer = password.generator.generatorAlgorithm {
            return true
        }
        return false
    }

    private func copyToClipboard(_ code: String) {
        #if os(iOS)
        UIPasteboard.general.string = code

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code, forType: .string)
        #endif

        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isTapped = true
        }

        withAnimation(.easeIn(duration: 0.3)) {
            showCopiedToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isTapped = false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                showCopiedToast = false
            }
        }
    }

    private var progressColor: Color {
        if progress > 0.5 {
            return .green
        } else if progress > 0.25 {
            return .orange
        } else {
            return .red
        }
    }

    private var flashOpacity: Double {
        guard isTimerBased else { return 1.0 }

        let p = min(max(progress, 0), 1)

        // Start flashing when less than 20% time remains
        guard p < 0.2 else { return 1.0 }

        // Calculate intensity (0.0 = 20% left, 1.0 = 0% left)
        let intensity = 1.0 - (p / 0.2)

        // Flash frequency increases subtly (1-2 Hz)
        let frequency = 1.0 + (1.0 * intensity)

        // Phase based on timeRemaining for continuous frequency changes
        let phase = timeRemaining * frequency * 2 * .pi

        // Amplitude increases with intensity (10%-20%)
        let amplitude = 0.10 + (0.10 * intensity)

        // Calculate opacity pulse using sine wave
        let pulse = amplitude * (0.5 - 0.5 * sin(phase))

        return 1.0 - pulse
    }

    private var scaleEffect: CGFloat {
        guard isTimerBased else { return 1.0 }

        let p = min(max(progress, 0), 1)

        // Start scaling when less than 20% time remains
        guard p < 0.2 else { return 1.0 }

        // Calculate intensity (0.0 = 20% left, 1.0 = 0% left)
        let intensity = 1.0 - (p / 0.2)

        // Use cubic curve for base scale growth
        let exponentialIntensity = intensity * intensity * intensity

        // Base scale grows subtly
        let baseScale = 1.0 + (0.03 * exponentialIntensity)

        // Pulsing effect that gets moderately faster (1.5-3 Hz)
        let pulseFrequency = 1.5 + (1.5 * intensity)
        let phase = timeRemaining * pulseFrequency * 2 * .pi

        // Pulse amplitude increases subtly
        let pulseAmplitude = 0.02 + (0.04 * exponentialIntensity)
        let pulse = pulseAmplitude * (0.5 + 0.5 * sin(phase))

        return baseScale + pulse
    }

    private var glowIntensity: Double {
        let p = min(max(progress, 0), 1)

        // Glow starts at 50% and increases to max at 0%
        guard p < 0.5 else { return 0.0 }

        // Calculate intensity (0.0 = 50% left, 1.0 = 0% left)
        let intensity = 1.0 - (p / 0.5)

        // Use quadratic curve for smooth buildup
        return intensity * intensity
    }

    private var glowColor: Color {
        let p = min(max(progress, 0), 1)

        // Glow is visible from 50% to 0%, so interpolate within that range
        // At 50% progress → green (hue 0.33)
        // At 0% progress → red (hue 0.0)
        let normalized = p / 0.5 // Maps 0.5→1.0, 0.0→0.0
        let hue = 0.33 * normalized

        // Increase saturation as urgency increases
        let saturation = 0.7 + 0.3 * (1 - normalized)

        return Color(hue: hue, saturation: saturation, brightness: 0.9)
    }

    private var textColor: Color {
        let p = min(max(progress, 0), 1)
        let threshold = 0.3

        // Keep fully readable above threshold
        if p > threshold {
            return .primary
        }

        // Below threshold, smoothly transition from dark to bright red
        // Normalize within visible range
        let normalized = 1 - (p / threshold)

        // Use cubic curve for smooth ramp
        let curve = normalized * normalized * normalized

        // Hue: stay near red (0.0)
        let hue = 0.0

        // Saturation: gradually increase from low to high
        let saturation = 0.5 + (curve * 0.4) // 50% → 90%

        // Brightness: start dark, get brighter
        // This is key for readability - we go from dark red to bright red
        let brightness = 0.3 + (curve * 0.65) // 30% → 95%

        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }

    private func updatePassword() {
        if let code = password.currentPassword {
            currentCode = code
        }

        if isTimerBased {
            timeRemaining = password.timeRemaining ?? 0
            progress = password.passwordProgress ?? 0
        }
    }
}

#Preview("TOTP - SHA256") {
    List {
        OTPCodeRow(password: createSHA256Password())
    }
}

#Preview("Multiple Algorithms") {
    List {
        ForEach(createMultiplePasswords(), id: \.name) { password in
            OTPCodeRow(password: password)
        }
    }
}

@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, *)
private func createSHA256Password() -> Password {
    guard let secretData = "JBSWY3DPEHPK3PXP".base32DecodedData,
          let generator = try? Generator(type: .timer(period: 30), hash: .sha256, secret: secretData, digits: 6) else {
        fatalError("Failed to create demo password")
    }
    return Password(name: "user@example.com", issuer: "GitHub", generator: generator)
}

@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, *)
private func createMultiplePasswords() -> [Password] {
    guard let secretData = "JBSWY3DPEHPK3PXP".base32DecodedData else { return [] }

    var passwords: [Password] = []

    if let gen = try? Generator(type: .timer(period: 30), hash: .sha1, secret: secretData, digits: 6) {
        passwords.append(Password(name: "user@example.com", issuer: "Google", generator: gen))
    }

    if let gen = try? Generator(type: .timer(period: 30), hash: .sha256, secret: secretData, digits: 6) {
        passwords.append(Password(name: "user@github.com", issuer: "GitHub", generator: gen))
    }

    if let gen = try? Generator(type: .timer(period: 30), hash: .sha512, secret: secretData, digits: 8) {
        passwords.append(Password(name: "admin@example.com", issuer: "AWS", generator: gen))
    }

    if let gen = try? Generator(type: .timer(period: 15), hash: .sha256, secret: secretData, digits: 6) {
        passwords.append(Password(name: "user@fast.com", issuer: "FastCorp (15s)", generator: gen))
    }

    return passwords
}
