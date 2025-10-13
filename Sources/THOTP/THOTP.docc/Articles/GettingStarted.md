# Getting Started with THOTP

Generate time-based and HMAC-based one-time passwords in your Swift app.

@Metadata {
    @PageKind(sampleCode)
}

## Overview

THOTP makes it easy to add two-factor authentication support to your app. This guide walks you through the basics of creating passwords, generating codes, and handling errors.

## Installation

Add THOTP to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/ericlewis/THOTP.git", from: "2.0.0")
]
```

Then import THOTP in your Swift files:

```swift
import THOTP
```

## Creating Your First TOTP Password

The most common use case is creating a time-based one-time password (TOTP) that changes every 30 seconds:

```swift
import THOTP
import Base32

// Decode your Base32 secret
let secret = "JBSWY3DPEHPK3PXP".base32DecodedData!

// Create a TOTP generator
let generator = try Generator(
    type: .timer(period: 30),    // 30-second intervals
    hash: .sha256,                // SHA-256 algorithm
    secret: secret,
    digits: 6                     // 6-digit codes
)

// Create the password object
let password = Password(
    name: "user@example.com",
    issuer: "MyApp",
    generator: generator
)

// Get the current code
if let code = password.currentPassword {
    print("Current code: \(code)")
}
```

## Checking Time Remaining

For TOTP passwords, you can check how much time is left before the code expires:

```swift
if let remaining = password.timeRemaining {
    print("Code expires in \(Int(remaining)) seconds")
}

// Or get the progress as a percentage
if let progress = password.passwordProgress {
    let percentage = Int(progress * 100)
    print("Progress: \(percentage)%")
}
```

## Creating HOTP Passwords

For counter-based passwords (HOTP), use a counter instead of a timer:

```swift
let hotpGenerator = try Generator(
    type: .counter(42),          // Counter value
    hash: .sha512,
    secret: secret,
    digits: 8                     // 8-digit codes
)

let hotpPassword = Password(
    name: "service@example.com",
    issuer: "HOTP Service",
    generator: hotpGenerator
)
```

> Note: HOTP passwords don't expire based on time. The counter must be incremented after each use.

## Handling Errors

THOTP uses Swift 6.2's typed throws for compile-time error safety:

```swift
do {
    let generator = try Generator(
        type: .timer(period: 30),
        hash: .sha256,
        secret: secret,
        digits: 6
    )
} catch OTPError.invalidDigits {
    print("Digits must be 6-8")
} catch OTPError.invalidPeriod {
    print("Period must be greater than 0")
} catch {
    print("Unexpected error: \(error)")
}
```

All errors are ``OTPError`` types with helpful localized descriptions.

## Next Steps

- Learn about <doc:ParsingURLs> to support `otpauth://` URLs
- Explore <doc:CreatingPasswords> for advanced configuration
- Read <doc:SecurityBestPractices> for production deployment

## See Also

- ``Password``
- ``Generator``
- ``OTPError``
