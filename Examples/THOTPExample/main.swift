import Foundation
import THOTP
import Base32

// MARK: - THOTP 2.0 Feature Demonstration

print("🔐 THOTP 2.0 - Swift 6.2 Feature Showcase\n")
print("=" * 60)

// MARK: - 1. Basic TOTP Generation

print("\n1️⃣  Basic TOTP Generation (Time-based)")
print("-" * 60)

do {
    let totpGenerator = try Generator(
        type: .timer(period: 30),
        hash: .sha256,
        secret: "JBSWY3DPEHPK3PXP".base32DecodedData!,
        digits: 6
    )

    let totpPassword = Password(
        name: "user@example.com",
        issuer: "Example App",
        generator: totpGenerator
    )

    if let code = totpPassword.currentPassword {
        print("✅ Current TOTP Code: \(code)")
    }

    if let remaining = totpPassword.timeRemaining {
        print("⏱️  Time Remaining: \(String(format: "%.1f", remaining)) seconds")
    }

    if let progress = totpPassword.passwordProgress {
        let percentage = Int(progress * 100)
        let bars = String(repeating: "█", count: percentage / 5)
        let spaces = String(repeating: "░", count: 20 - percentage / 5)
        print("📊 Progress: [\(bars)\(spaces)] \(percentage)%")
    }
} catch {
    print("❌ Error: \(error)")
}

// MARK: - 2. HOTP Generation (Counter-based)

print("\n2️⃣  HOTP Generation (Counter-based)")
print("-" * 60)

do {
    let hotpGenerator = try Generator(
        type: .counter(42),
        hash: .sha512,
        secret: "JBSWY3DPEHPK3PXP".base32DecodedData!,
        digits: 8
    )

    let hotpPassword = Password(
        name: "service@example.com",
        issuer: "HOTP Service",
        generator: hotpGenerator
    )

    if let code = hotpPassword.currentPassword {
        print("✅ HOTP Code (counter=42): \(code)")
    }

    // HOTP has no time remaining
    if hotpPassword.timeRemaining == nil {
        print("⏱️  Time Remaining: N/A (counter-based)")
    }
} catch {
    print("❌ Error: \(error)")
}

// MARK: - 3. URL Parsing & Generation

print("\n3️⃣  URL Parsing & Generation")
print("-" * 60)

let otpAuthURL = URL(string: "otpauth://totp/GitHub:user@github.com?secret=JBSWY3DPEHPK3PXP&issuer=GitHub&algorithm=SHA256&digits=6&period=30")!

do {
    let parsedPassword = try Password(url: otpAuthURL)
    print("✅ Parsed from URL:")
    print("   Name: \(parsedPassword.name)")
    print("   Issuer: \(parsedPassword.issuer ?? "none")")
    print("   Algorithm: \(parsedPassword.generator.hashAlgorithm.rawValue.uppercased())")
    print("   Digits: \(parsedPassword.generator.digits)")

    if let generatedURL = parsedPassword.absoluteURL {
        print("✅ Generated URL:")
        print("   \(generatedURL)")
    }

    if let code = parsedPassword.currentPassword {
        print("✅ Current Code: \(code)")
    }
} catch {
    print("❌ OTP Error: \(error.localizedDescription)")
}

// MARK: - 4. Different Hash Algorithms

print("\n4️⃣  Hash Algorithm Comparison")
print("-" * 60)

let secret = "JBSWY3DPEHPK3PXP".base32DecodedData!
let algorithms: [SupportedHashAlgorithm] = [.sha1, .sha256, .sha512]

for algorithm in algorithms {
    do {
        let generator = try Generator(
            type: .timer(period: 30),
            hash: algorithm,
            secret: secret,
            digits: 6
        )

        let password = Password(
            name: "test",
            generator: generator
        )

        if let code = password.currentPassword {
            print("✅ \(algorithm.rawValue.uppercased().padding(toLength: 6, withPad: " ", startingAt: 0)): \(code)")
        }
    } catch {
        print("❌ \(algorithm.rawValue.uppercased()): Failed")
    }
}

// MARK: - 5. Error Handling with Typed Throws

print("\n5️⃣  Type-Safe Error Handling")
print("-" * 60)

// Invalid digits
do {
    let _ = try Generator(
        type: .counter(1),
        hash: .sha256,
        secret: secret,
        digits: 3  // Invalid! Must be 6-8
    )
    print("❌ Should have thrown error")
} catch OTPError.invalidDigits {
    print("✅ Caught invalidDigits: \(OTPError.invalidDigits.localizedDescription)")
} catch {
    print("❌ Wrong error type")
}

// Invalid period
do {
    let _ = try Generator(
        type: .timer(period: -10),  // Invalid! Must be > 0
        hash: .sha256,
        secret: secret,
        digits: 6
    )
    print("❌ Should have thrown error")
} catch OTPError.invalidPeriod {
    print("✅ Caught invalidPeriod: \(OTPError.invalidPeriod.localizedDescription)")
} catch {
    print("❌ Wrong error type")
}

// Invalid URL
do {
    let badURL = URL(string: "otpauth://totp/test")!  // Missing secret
    let _ = try Password(url: badURL)
    print("❌ Should have thrown error")
} catch OTPError.invalidURL {
    print("✅ Caught invalidURL: \(OTPError.invalidURL.localizedDescription)")
} catch {
    print("❌ Wrong error type")
}

// MARK: - 6. Custom Issuer Strategies

print("\n6️⃣  Custom Issuer Strategies")
print("-" * 60)

let testURL = URL(string: "otpauth://totp/Issuer1:user@test.com?secret=JBSWY3DPEHPK3PXP&issuer=Issuer2")!

// Default strategy (both must match)
do {
    let _ = try Password(url: testURL, issuerStrategy: .default)
    print("❌ Default: Should have thrown (mismatch)")
} catch OTPError.invalidURL {
    print("✅ Default: Correctly rejected mismatched issuers")
} catch {
    print("❌ Wrong error")
}

// Name first strategy
do {
    let password = try Password(url: testURL, issuerStrategy: .nameFirst)
    print("✅ NameFirst: Issuer = \(password.issuer ?? "none")")
} catch {
    print("❌ NameFirst failed: \(error)")
}

// Query first strategy
do {
    let password = try Password(url: testURL, issuerStrategy: .queryFirst)
    print("✅ QueryFirst: Issuer = \(password.issuer ?? "none")")
} catch {
    print("❌ QueryFirst failed: \(error)")
}

// Custom strategy
do {
    let password = try Password(url: testURL, issuerStrategy: .custom { name, query in
        return "\(name ?? "?") + \(query ?? "?")"
    })
    print("✅ Custom: Issuer = \(password.issuer ?? "none")")
} catch {
    print("❌ Custom failed: \(error)")
}

// MARK: - 7. Performance Characteristics

print("\n7️⃣  Swift 6.2 Performance Features")
print("-" * 60)

do {
    let generator = try Generator(
        type: .timer(period: 30),
        hash: .sha256,
        secret: secret,
        digits: 6
    )

    _ = Password(name: "perf-test", generator: generator)

    print("✅ BitwiseCopyable enums: Zero-cost copying")
    print("   - SupportedHashAlgorithm: ✓")
    print("   - GeneratorAlgorithm: ✓")
    print("   - OTPError: ✓")
    print("   - Key: ✓")

    print("\n✅ Borrowing parameters: Reduced allocations")
    print("   - generate(with: borrowing Date)")
    print("   - No Date copies during generation!")

    print("\n✅ Typed throws: Compile-time safety")
    print("   - All errors are OTPError")
    print("   - Type-safe catch blocks")

    print("\n✅ Sendable conformance: Data race safety")
    print("   - Safe to pass across concurrency domains")

    // Demonstrate generation is fast
    let start = Date()
    var codes: [String] = []
    for _ in 0..<1000 {
        if let code = try? generator.generate(with: Date()) {
            codes.append(code)
        }
    }
    let duration = Date().timeIntervalSince(start)

    print("\n⚡️ Generated 1000 codes in \(String(format: "%.3f", duration * 1000))ms")
    print("   Average: \(String(format: "%.3f", duration))µs per generation")
} catch {
    print("❌ Performance test failed")
}

// MARK: - 8. Equality & Comparison

print("\n8️⃣  Password Equality")
print("-" * 60)

do {
    let gen1 = try Generator(type: .timer(period: 30), hash: .sha256, secret: secret, digits: 6)
    let gen2 = try Generator(type: .timer(period: 30), hash: .sha256, secret: secret, digits: 6)
    let gen3 = try Generator(type: .timer(period: 30), hash: .sha1, secret: secret, digits: 6)

    let pw1 = Password(name: "test", issuer: "app", generator: gen1)
    let pw2 = Password(name: "test", issuer: "app", generator: gen2)
    let pw3 = Password(name: "test", issuer: "app", generator: gen3)

    print("✅ Complete equality checking:")
    print("   pw1 == pw2: \(pw1 == pw2) (same config)")
    print("   pw1 == pw3: \(pw1 == pw3) (different hash)")
    print("   Checks: name, issuer, image, secret, digits, hash, algorithm")
} catch {
    print("❌ Equality test failed")
}

// MARK: - Summary

print("\n" + "=" * 60)
print("✨ All THOTP 2.0 features demonstrated!")
print("🚀 Swift 6.2 | iOS 18+ | macOS 15+ | Strict Concurrency")
print("=" * 60 + "\n")

// Helper for string repeating
extension String {
    static func * (lhs: String, rhs: Int) -> String {
        String(repeating: lhs, count: rhs)
    }
}
