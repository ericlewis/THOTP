import SwiftUI
import THOTP

struct ManualEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var newPassword: Password?

    @State private var urlString: String = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("otpauth://totp/...", text: $urlString)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                } header: {
                    Text("OTP URL")
                } footer: {
                    Text("Paste an otpauth:// URL from your authenticator service")
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Example URL:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("otpauth://totp/Example:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Add Manually")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", role: .confirm) {
                        addPassword()
                    }
                    .disabled(urlString.isEmpty)
                }
            }
        }
    }

    private func addPassword() {
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL format"
            return
        }

        do {
            let password = try Password(url: url)
            newPassword = password
            dismiss()
        } catch {
            errorMessage = "Failed to parse OTP URL: \(error.localizedDescription)"
        }
    }
}
