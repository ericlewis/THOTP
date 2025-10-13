# ``THOTP``

A modern Swift library for generating time-based and HMAC-based one-time passwords.

@Metadata {
    @DisplayName("THOTP")
    @TitleHeading("Framework")
}

## Overview

THOTP provides a pure Swift implementation of TOTP (Time-based One-Time Password) and HOTP (HMAC-based One-Time Password) algorithms, fully compatible with the [Google Authenticator URI format](https://github.com/google/google-authenticator/wiki/Key-Uri-Format).

Built with Swift 6.2's latest features including strict concurrency, typed throws, and BitwiseCopyable for maximum performance and safety.

```swift
import THOTP

// Create a TOTP generator
let generator = try Generator(
    type: .timer(period: 30),
    hash: .sha256,
    secret: secretData,
    digits: 6
)

let password = Password(
    name: "user@example.com",
    issuer: "MyApp",
    generator: generator
)

// Generate current code
if let code = password.currentPassword {
    print("Current code: \(code)")
}
```

### Key Features

- **Standards Compliant**: Fully implements RFC 6238 (TOTP) and RFC 4226 (HOTP)
- **Modern Swift**: Built with Swift 6.2, strict concurrency, and typed throws
- **High Performance**: BitwiseCopyable enums, borrowing parameters, optimized algorithms
- **Type Safe**: Compile-time error checking with `throws(OTPError)`
- **Flexible**: Multiple hash algorithms (SHA1, SHA256, SHA512) and configurable parameters
- **URL Compatible**: Parse and generate `otpauth://` URLs
- **Sendable**: Safe to use across concurrency boundaries

### Platform Support

- iOS 18.0+
- macOS 15.0+
- tvOS 18.0+
- watchOS 11.0+

## Topics

### Getting Started

- <doc:GettingStarted>
- <doc:CreatingPasswords>
- <doc:ParsingURLs>

### Essentials

- ``Password``
- ``Generator``
- ``OTPError``

### Protocols

- ``PasswordProtocol``
- ``GeneratorProtocol``

### Configuration

- ``GeneratorAlgorithm``
- ``SupportedHashAlgorithm``
- ``IssuerStrategy``

### Advanced Topics

- <doc:CustomImplementations>
- <doc:SecurityBestPractices>
- <doc:PerformanceOptimizations>

### Error Handling

- ``OTPError``
- <doc:ErrorHandling>
