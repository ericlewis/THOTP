import SwiftUI
import THOTP
import Base32

struct ContentView: View {
    @State private var passwords: [Password] = []

    var body: some View {
        NavigationStack {
            List {
                ForEach(passwords, id: \.name) { password in
                    PasswordRowView(password: password)
                }
            }
            .navigationTitle("THOTP Demo")
        }
        .task {
            loadPasswords()
        }
    }

    private func loadPasswords() {
        guard let secretData = "JBSWY3DPEHPK3PXP".base32DecodedData else { return }

        var examples: [Password] = []

        // SHA1 - 6 digits (Google Authenticator default)
        if let generator = try? Generator(
            type: .timer(period: 30),
            hash: .sha1,
            secret: secretData,
            digits: 6
        ) {
            examples.append(Password(
                name: "user@example.com",
                issuer: "Google (SHA1)",
                generator: generator
            ))
        }

        // SHA256 - 6 digits
        if let generator = try? Generator(
            type: .timer(period: 30),
            hash: .sha256,
            secret: secretData,
            digits: 6
        ) {
            examples.append(Password(
                name: "user@example.com",
                issuer: "GitHub (SHA256)",
                generator: generator
            ))
        }

        // SHA512 - 8 digits
        if let generator = try? Generator(
            type: .timer(period: 30),
            hash: .sha512,
            secret: secretData,
            digits: 8
        ) {
            examples.append(Password(
                name: "admin@example.com",
                issuer: "AWS (SHA512)",
                generator: generator
            ))
        }

        // Short period (15 seconds)
        if let generator = try? Generator(
            type: .timer(period: 15),
            hash: .sha256,
            secret: secretData,
            digits: 6
        ) {
            examples.append(Password(
                name: "user@example.com",
                issuer: "FastCorp (15s)",
                generator: generator
            ))
        }

        // Counter-based (HOTP)
        if let generator = try? Generator(
            type: .counter(0),
            hash: .sha1,
            secret: secretData,
            digits: 6
        ) {
            examples.append(Password(
                name: "user@example.com",
                issuer: "Legacy (HOTP)",
                generator: generator
            ))
        }

        passwords = examples
    }
}

struct PasswordRowView: View {
    let password: Password
    @State private var currentCode: String = "------"
    @State private var timeRemaining: TimeInterval = 0
    @State private var progress: Double = 0

    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
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
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.medium)

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

#Preview {
    ContentView()
}
