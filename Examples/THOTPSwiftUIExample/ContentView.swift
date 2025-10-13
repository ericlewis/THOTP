import SwiftUI
import THOTP
import Base32

struct ContentView: View {
    @State private var passwords: [Password] = []

    var body: some View {
        NavigationStack {
            List(passwords, id: \.name) { password in
                PasswordRowView(password: password)
            }
            .navigationTitle("THOTP Examples")
        }
        .task {
            await loadPasswords()
        }
    }

    private func loadPasswords() async {
        // Sample secret for demo purposes
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
