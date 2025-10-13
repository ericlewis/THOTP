import SwiftUI

/// A SwiftUI view that displays a list of OTP passwords.
///
/// This view presents multiple OTP passwords in a list format, each showing
/// its current code and countdown timer (for TOTP).
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, *)
public struct OTPCodeList: View {
    let passwords: [Password]

    public init(passwords: [Password]) {
        self.passwords = passwords
    }

    public var body: some View {
        List(passwords, id: \.name) { password in
            OTPCodeRow(password: password)
        }
    }
}

#Preview("Demo Passwords") {
    OTPCodeList(passwords: createDemoPasswords())
}

@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, *)
private func createDemoPasswords() -> [Password] {
    guard let secretData = "JBSWY3DPEHPK3PXP".base32DecodedData else { return [] }

    var examples: [Password] = []

    if let gen = try? Generator(type: .timer(period: 30), hash: .sha1, secret: secretData, digits: 6) {
        examples.append(Password(name: "user@example.com", issuer: "Google", generator: gen))
    }

    if let gen = try? Generator(type: .timer(period: 30), hash: .sha256, secret: secretData, digits: 6) {
        examples.append(Password(name: "user@example.com", issuer: "GitHub", generator: gen))
    }

    if let gen = try? Generator(type: .timer(period: 30), hash: .sha512, secret: secretData, digits: 8) {
        examples.append(Password(name: "admin@example.com", issuer: "AWS", generator: gen))
    }

    if let gen = try? Generator(type: .timer(period: 15), hash: .sha256, secret: secretData, digits: 6) {
        examples.append(Password(name: "user@example.com", issuer: "FastCorp (15s)", generator: gen))
    }

    if let gen = try? Generator(type: .counter(0), hash: .sha1, secret: secretData, digits: 6) {
        examples.append(Password(name: "user@example.com", issuer: "Legacy (HOTP)", generator: gen))
    }

    return examples
}
