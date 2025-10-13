# Creating Passwords

Learn about all the configuration options for TOTP and HOTP passwords.

## Overview

``Password`` objects contain the metadata and generator for producing one-time passwords. This guide covers all configuration options and use cases.

## Basic TOTP Password

The most common configuration uses 30-second periods with SHA-256:

```swift
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
```

## Generator Types

### Time-Based (TOTP)

Codes change at regular time intervals:

```swift
let generator = try Generator(
    type: .timer(period: 30),  // Changes every 30 seconds
    hash: .sha256,
    secret: secretData,
    digits: 6
)
```

Common periods:
- **30 seconds** (most common, recommended)
- **60 seconds** (some services)
- Custom periods are supported but may cause compatibility issues

### Counter-Based (HOTP)

Codes change based on a counter value:

```swift
let generator = try Generator(
    type: .counter(0),  // Start at counter 0
    hash: .sha256,
    secret: secretData,
    digits: 6
)
```

> Important: You must increment the counter after each successful authentication. THOTP doesn't automatically increment counters.

## Hash Algorithms

Choose from three SHA algorithms:

### SHA-256 (Recommended)

Modern, secure, and widely supported:

```swift
let generator = try Generator(
    type: .timer(period: 30),
    hash: .sha256,  // ✅ Best choice for new implementations
    secret: secretData,
    digits: 6
)
```

### SHA-512 (Most Secure)

Highest security, but less common:

```swift
let generator = try Generator(
    type: .timer(period: 30),
    hash: .sha512,  // Maximum security
    secret: secretData,
    digits: 6
)
```

### SHA-1 (Legacy)

Only use for compatibility with older systems:

```swift
let generator = try Generator(
    type: .timer(period: 30),
    hash: .sha1,  // ⚠️ Cryptographically weak, avoid if possible
    secret: secretData,
    digits: 6
)
```

## Code Length

Choose between 6, 7, or 8 digits:

```swift
// 6 digits (standard)
let gen6 = try Generator(type: .timer(period: 30), hash: .sha256, secret: secretData, digits: 6)

// 7 digits (uncommon)
let gen7 = try Generator(type: .timer(period: 30), hash: .sha256, secret: secretData, digits: 7)

// 8 digits (higher security)
let gen8 = try Generator(type: .timer(period: 30), hash: .sha256, secret: secretData, digits: 8)
```

> Note: 6 digits is the standard and most widely supported. 8 digits provides better security at the cost of usability.

## Password Metadata

Add metadata to identify and display passwords:

```swift
let password = Password(
    name: "user@example.com",          // Account identifier
    issuer: "GitHub",                   // Service name
    image: URL(string: "https://..."), // Optional icon
    generator: generator
)
```

### Name Field

The account name or identifier:
- Email address: `user@example.com`
- Username: `john_doe`
- Account ID: `12345`

### Issuer Field

The service or organization name:
- Appears in authenticator apps
- Helps users identify accounts
- Recommended for better UX

### Image Field

Optional icon URL:
- Not part of the official spec
- Some authenticator apps support it
- Useful for visual identification

## Using Constants

THOTP provides constants for common values:

```swift
// Use default values
let generator = try Generator(
    type: .timer(period: GeneratorAlgorithm.defaultPeriod),  // 30 seconds
    hash: .sha256,
    secret: secretData,
    digits: Generator.defaultDigits  // 6 digits
)
```

## Generating Codes

### Current Code

Get the code for the current time:

```swift
if let code = password.currentPassword {
    print("Enter this code: \(code)")
}
```

### Code at Specific Time

Generate a code for any specific time:

```swift
let specificDate = Date(timeIntervalSince1970: 1234567890)
let code = try password.generator.generate(with: specificDate)
```

### Time Information

For TOTP, check remaining time:

```swift
if let remaining = password.timeRemaining {
    print("Code expires in \(Int(remaining)) seconds")
}

if let progress = password.passwordProgress {
    // progress is 0.0 to 1.0
    let percentage = Int(progress * 100)
    print("Code is \(percentage)% through its lifetime")
}
```

> Note: `timeRemaining` and `passwordProgress` return `nil` for HOTP passwords.

## Password Comparison

Passwords can be compared for equality:

```swift
let pw1 = Password(name: "test", issuer: "app", generator: gen1)
let pw2 = Password(name: "test", issuer: "app", generator: gen2)

if pw1 == pw2 {
    print("Same password configuration")
}
```

The equality check compares:
- Name
- Issuer
- Image URL
- Secret
- Digits
- Hash algorithm
- Generator algorithm type

## Error Handling

Generator creation validates all parameters:

```swift
do {
    let generator = try Generator(
        type: .timer(period: 30),
        hash: .sha256,
        secret: secretData,
        digits: 6
    )
} catch OTPError.invalidDigits {
    // Digits must be 6-8
} catch OTPError.invalidPeriod {
    // Period must be > 0
} catch {
    // Other errors
}
```

All validation errors are caught at initialization, not during code generation.

## Best Practices

1. **Use SHA-256**: Best balance of security and compatibility
2. **Stick to 30-second periods**: Industry standard
3. **Use 6 digits**: Most user-friendly
4. **Always include issuer**: Better UX in authenticator apps
5. **Store secrets securely**: Use Keychain, never plain text
6. **Validate inputs early**: Let THOTP validate during initialization

## See Also

- ``Password``
- ``Generator``
- ``GeneratorAlgorithm``
- ``SupportedHashAlgorithm``
- <doc:SecurityBestPractices>
