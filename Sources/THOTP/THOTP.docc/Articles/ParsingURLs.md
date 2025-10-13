# Parsing OTP URLs

Parse and generate `otpauth://` URLs for interoperability with other authenticator apps.

## Overview

THOTP fully supports the Google Authenticator URI format, allowing you to:
- Parse QR code data from other services
- Generate QR codes for your own services
- Import/export passwords between apps

## Parsing an otpauth:// URL

Parse a standard OTP auth URL directly into a ``Password`` object:

```swift
let url = URL(string: "otpauth://totp/GitHub:user@github.com?secret=JBSWY3DPEHPK3PXP&issuer=GitHub&algorithm=SHA256&digits=6&period=30")!

do {
    let password = try Password(url: url)

    print("Name: \(password.name)")           // user@github.com
    print("Issuer: \(password.issuer ?? "")")  // GitHub
    print("Algorithm: \(password.generator.hashAlgorithm)")  // sha256
    print("Digits: \(password.generator.digits)")            // 6

} catch {
    print("Invalid URL: \(error.localizedDescription)")
}
```

## Generating URLs

Convert a ``Password`` back into a URL for sharing or QR code generation:

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

if let url = password.absoluteURL {
    print(url)
    // otpauth://totp/MyApp:user@example.com?secret=...&issuer=MyApp&...
}
```

> Important: The `absoluteURL` property returns an optional `URL?` to safely handle any URL construction errors.

## URL Components

An `otpauth://` URL contains these components:

### Required
- **type**: Either `totp` or `hotp`
- **label**: The account name (after the path)
- **secret**: Base32-encoded shared secret

### Optional
- **issuer**: Service name (both in label and query parameter)
- **algorithm**: Hash algorithm (SHA1, SHA256, SHA512)
- **digits**: Number of digits (6-8)
- **period**: Time step for TOTP (typically 30 seconds)
- **counter**: Counter value for HOTP
- **image**: URL to an image for the service

## Issuer Strategies

When parsing URLs, the issuer can appear in two places:
1. As a prefix in the label: `otpauth://totp/GitHub:user@github.com`
2. As a query parameter: `?issuer=GitHub`

THOTP offers different strategies for handling this:

### Default Strategy

Validates that both issuers match if both are present:

```swift
let password = try Password(url: url, issuerStrategy: .default)
```

### Name First Strategy

Prefers the issuer from the label:

```swift
let password = try Password(url: url, issuerStrategy: .nameFirst)
```

### Query First Strategy

Prefers the issuer from the query parameter:

```swift
let password = try Password(url: url, issuerStrategy: .queryFirst)
```

### Custom Strategy

Implement custom logic with a closure:

```swift
let password = try Password(url: url, issuerStrategy: .custom { nameIssuer, queryIssuer in
    // Return your preferred issuer
    return nameIssuer ?? queryIssuer ?? "Unknown"
})
```

## Error Handling

URL parsing can fail for several reasons:

```swift
do {
    let password = try Password(url: url)
} catch OTPError.invalidURL {
    // Malformed URL or missing required parameters
    print("The URL format is invalid")
} catch {
    print("Unexpected error: \(error)")
}
```

Common causes of `invalidURL` errors:
- Missing or invalid secret
- Invalid counter value for HOTP
- Malformed URL structure
- Mismatched issuers (with default strategy)

## QR Code Integration

Combine with a QR code library to scan authenticator codes:

```swift
// After scanning QR code and getting URL string
if let url = URL(string: scannedString),
   let password = try? Password(url: url) {
    // Save password and start generating codes
    savePassword(password)
}
```

## See Also

- ``Password/init(url:)``
- ``Password/init(url:issuerStrategy:)``
- ``Password/absoluteURL``
- ``IssuerStrategy``
