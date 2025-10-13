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
                            .shadow(color: isRedZone ? .red.opacity(0.8) : .clear, radius: isRedZone ? 12 : 0)
                            .shadow(color: isRedZone ? .red.opacity(0.4) : .clear, radius: isRedZone ? 24 : 0)
                            .animation(Animation.easeInOut(duration: 0.2), value: flashOpacity)
                            .animation(Animation.easeInOut(duration: 0.2), value: scaleEffect)
                            .animation(Animation.easeInOut(duration: 0.3), value: isRedZone)

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
        return progress < 0.25
    }

    private var flashOpacity: Double {
        guard isTimerBased else { return 1.0 }

        let p = min(max(progress, 0), 1)

        // Start flashing when less than 25% time remains
        guard p < 0.25 else { return 1.0 }

        // Calculate flash intensity (0.0 = subtle, 1.0 = intense)
        let intensity = 1.0 - (p / 0.25)

        // Flash frequency increases as time runs out (0.5-2 Hz)
        let frequency = 0.5 + (1.5 * intensity)

        // Phase based on sub-second timing
        let phase = (timeRemaining.truncatingRemainder(dividingBy: 1.0 / frequency)) * frequency * 2 * .pi

        // Amplitude increases with intensity (subtle: 12%, intense: 35%)
        let amplitude = 0.12 + (0.23 * intensity)

        // Calculate opacity pulse (stays mostly visible, dips noticeably)
        let pulse = amplitude * (1.0 - cos(phase)) / 2.0

        return 1.0 - pulse
    }

    private var scaleEffect: CGFloat {
        guard isTimerBased else { return 1.0 }

        let p = min(max(progress, 0), 1)

        // Start scaling earlier (when less than 40% time remains) for gradual buildup
        guard p < 0.4 else { return 1.0 }

        // Calculate intensity based on how much total time has elapsed (0.0 = subtle, 1.0 = intense)
        let intensity = 1.0 - (p / 0.4)

        // Get the elapsed time within the current period (0.0 = start of period, 1.0 = end of period)
        guard case .timer(let period) = password.generator.generatorAlgorithm else { return 1.0 }
        let elapsedInPeriod = 1.0 - (timeRemaining / period)

        // Base scale grows as overall progress decreases (tied to total progress)
        let baseScale = 1.0 + (0.03 * intensity * intensity)

        // Breathing effect tied to position in current period
        // Scale grows as we progress through each period, creating breathing tied to countdown
        let breathingAmplitude = 0.02 + (0.04 * intensity * intensity)
        let breathing = breathingAmplitude * elapsedInPeriod

        return baseScale + breathing
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
