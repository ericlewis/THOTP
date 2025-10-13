# Security Best Practices

Protect your users' secrets and implement two-factor authentication securely.

## Overview

When implementing one-time password authentication, security is paramount. Follow these best practices to ensure your implementation is secure.

## Secure Secret Storage

**Never store secrets in plain text.** Use the iOS Keychain or similar secure storage:

```swift
import Security

func storeSecret(_ secret: Data, for account: String) throws {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: account,
        kSecValueData as String: secret,
        kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ]

    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
        throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
    }
}
```

> Tip: Consider using [Valet](https://github.com/square/Valet) for simpler keychain access, or the [Valet-THOTP](https://github.com/ericlewis/Valet-THOTP) integration.

## Use Strong Hash Algorithms

Prefer SHA-256 or SHA-512 over SHA-1:

```swift
// ✅ Good: Modern, secure hash
let generator = try Generator(
    type: .timer(period: 30),
    hash: .sha256,  // or .sha512
    secret: secret,
    digits: 6
)

// ⚠️ Avoid: SHA-1 is cryptographically weak
let generator = try Generator(
    type: .timer(period: 30),
    hash: .sha1,  // Only use if required for compatibility
    secret: secret,
    digits: 6
)
```

> Note: SHA-1 is supported for compatibility with legacy systems but should be avoided in new implementations.

## Protect Secrets in Memory

THOTP is designed with Swift 6.2's `Sendable` protocol for thread safety, but take additional precautions:

```swift
// Use local scope to limit secret lifetime
func generateCode(secretString: String) throws -> String? {
    guard let secret = secretString.base32DecodedData else {
        throw OTPError.invalidURL
    }

    let generator = try Generator(
        type: .timer(period: 30),
        hash: .sha256,
        secret: secret,
        digits: 6
    )

    return try? generator.generate(with: Date())
    // Secret and generator go out of scope here
}
```

## Validate Time Windows

For TOTP, accept codes from a small time window to account for clock drift:

```swift
func verifyCode(_ code: String, for password: Password, windowSize: Int = 1) -> Bool {
    let now = Date()

    // Check current period
    if let currentCode = try? password.generator.generate(with: now),
       currentCode == code {
        return true
    }

    // Check adjacent periods (±30 seconds with windowSize=1)
    let period: TimeInterval = 30
    for offset in 1...windowSize {
        // Past window
        let pastDate = now.addingTimeInterval(-period * Double(offset))
        if let pastCode = try? password.generator.generate(with: pastDate),
           pastCode == code {
            return true
        }

        // Future window
        let futureDate = now.addingTimeInterval(period * Double(offset))
        if let futureCode = try? password.generator.generate(with: futureDate),
           futureCode == code {
            return true
        }
    }

    return false
}
```

## Implement Rate Limiting

Protect against brute force attacks:

```swift
actor RateLimiter {
    private var attempts: [String: (count: Int, resetTime: Date)] = [:]

    func checkAttempt(for account: String, maxAttempts: Int = 3, window: TimeInterval = 300) -> Bool {
        let now = Date()

        if let record = attempts[account] {
            // Reset if window expired
            if now > record.resetTime {
                attempts[account] = (count: 1, resetTime: now.addingTimeInterval(window))
                return true
            }

            // Check if too many attempts
            if record.count >= maxAttempts {
                return false
            }

            // Increment attempts
            attempts[account] = (count: record.count + 1, resetTime: record.resetTime)
            return true
        }

        // First attempt
        attempts[account] = (count: 1, resetTime: now.addingTimeInterval(window))
        return true
    }
}
```

## Secure Secret Transmission

When transmitting secrets to users (e.g., during enrollment):

1. **Use HTTPS**: Always transmit secrets over TLS
2. **Use QR Codes**: Display QR codes instead of showing raw secrets
3. **One-Time Display**: Show secrets only once during setup
4. **User Confirmation**: Verify user has saved the secret before proceeding

```swift
// Generate QR code with proper error handling
func generateQRCode(from password: Password) -> UIImage? {
    guard let url = password.absoluteURL else {
        return nil
    }

    let data = url.absoluteString.data(using: .utf8)
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
        return nil
    }

    filter.setValue(data, forKey: "inputMessage")
    filter.setValue("M", forKey: "inputCorrectionLevel")

    guard let outputImage = filter.outputImage else {
        return nil
    }

    let transform = CGAffineTransform(scaleX: 10, y: 10)
    let scaledImage = outputImage.transformed(by: transform)

    return UIImage(ciImage: scaledImage)
}
```

## Audit Logging

Log authentication attempts for security monitoring:

```swift
func logAuthAttempt(
    account: String,
    success: Bool,
    timestamp: Date = Date()
) {
    let entry = """
    OTP Auth: account=\(account) \
    success=\(success) \
    timestamp=\(timestamp.ISO8601Format())
    """

    // Log to your security monitoring system
    os_log("%{public}@", log: .security, type: .info, entry)
}
```

## Secure Comparison

Use constant-time comparison to prevent timing attacks:

```swift
func secureCompare(_ a: String, _ b: String) -> Bool {
    guard a.count == b.count else { return false }

    var result = 0
    for (charA, charB) in zip(a.utf8, b.utf8) {
        result |= Int(charA ^ charB)
    }

    return result == 0
}
```

## Backup Codes

Always provide backup codes for account recovery:

```swift
func generateBackupCodes(count: Int = 10) -> [String] {
    (0..<count).map { _ in
        let bytes = (0..<8).map { _ in UInt8.random(in: 0...255) }
        return Data(bytes).base32EncodedString
            .prefix(16)
            .split(every: 4)
            .joined(separator: "-")
    }
}

extension String {
    func split(every: Int) -> [String] {
        var result: [String] = []
        var current = startIndex

        while current < endIndex {
            let next = index(current, offsetBy: every, limitedBy: endIndex) ?? endIndex
            result.append(String(self[current..<next]))
            current = next
        }

        return result
    }
}
```

## See Also

- ``Password``
- ``Generator``
- ``OTPError``
- <doc:CreatingPasswords>
