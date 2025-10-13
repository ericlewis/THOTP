import SwiftUI
import THOTP

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
