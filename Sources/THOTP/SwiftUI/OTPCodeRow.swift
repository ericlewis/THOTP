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
                            .foregroundStyle(isRedZone ? .red : .primary)
                            .opacity(flashOpacity)
                            .scaleEffect(scaleEffect)
                            .shadow(color: .red.opacity(glowIntensity * 0.8), radius: 8 + (glowIntensity * 8))
                            .shadow(color: .red.opacity(glowIntensity * 0.5), radius: 16 + (glowIntensity * 16))

                        Text("\(Int(timeRemaining))s")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text(currentCode)
                        .font(.system(.title2, design: .monospaced))
                        .fontWeight(.medium)
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
    }

    private var isTimerBased: Bool {
        if case .timer = password.generator.generatorAlgorithm {
            return true
        }
        return false
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

    private var isRedZone: Bool {
        return progress < 0.2
    }

    private var flashOpacity: Double {
        guard isTimerBased else { return 1.0 }

        let p = min(max(progress, 0), 1)

        // Start flashing when less than 20% time remains
        guard p < 0.2 else { return 1.0 }

        // Calculate intensity (0.0 = 20% left, 1.0 = 0% left)
        let intensity = 1.0 - (p / 0.2)

        // Flash frequency increases dramatically (1-5 Hz)
        let frequency = 1.0 + (4.0 * intensity)

        // Phase based on timeRemaining for continuous frequency changes
        let phase = timeRemaining * frequency * 2 * .pi

        // Amplitude increases with intensity (15%-45%)
        let amplitude = 0.15 + (0.30 * intensity)

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

        // Use cubic curve for very dramatic base scale growth
        let exponentialIntensity = intensity * intensity * intensity

        // Base scale grows dramatically
        let baseScale = 1.0 + (0.08 * exponentialIntensity)

        // Pulsing effect that gets much faster (2-8 Hz)
        let pulseFrequency = 2.0 + (6.0 * intensity)
        let phase = timeRemaining * pulseFrequency * 2 * .pi

        // Pulse amplitude increases dramatically
        let pulseAmplitude = 0.03 + (0.12 * exponentialIntensity)
        let pulse = pulseAmplitude * (0.5 + 0.5 * sin(phase))

        return baseScale + pulse
    }

    private var glowIntensity: Double {
        let p = min(max(progress, 0), 1)

        // Glow starts at 20% and increases to max at 0%
        guard p < 0.2 else { return 0.0 }

        // Calculate intensity (0.0 = 20% left, 1.0 = 0% left)
        let intensity = 1.0 - (p / 0.2)

        // Use quadratic curve for smooth buildup
        return intensity * intensity
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
