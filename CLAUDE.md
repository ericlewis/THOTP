# CLAUDE.md

This file provides guidance for AI assistants working with the THOTP codebase.

## Project Overview

THOTP is a pure Swift library for generating Time-based One-Time Passwords (TOTP) and HMAC-based One-Time Passwords (HOTP). It is compatible with the Google Authenticator URI scheme (`otpauth://`).

- **Language:** Swift 5.1+
- **License:** MIT
- **Author:** Eric Lewis (@ericlewis)
- **Platforms:** iOS 13.0+, macOS 10.15+, tvOS 13.0+, watchOS 6.0+

## Repository Structure

```
THOTP/
├── Sources/THOTP/
│   ├── Protocols/                    # Protocol definitions
│   │   ├── PasswordProtocol.swift    # OTP password metadata
│   │   └── GeneratorProtocol.swift   # OTP generation logic
│   ├── Extensions/                   # Protocol extension implementations
│   │   ├── PasswordProtocol+CurrentPassword.swift
│   │   ├── PasswordProtocol+Equatable.swift
│   │   ├── PasswordProtocol+URL.swift
│   │   ├── GeneratorProtocol+Generate.swift
│   │   └── GeneratorProtocol+Validators.swift
│   ├── Enums/                        # Type definitions
│   │   ├── GeneratorAlgorithm.swift  # HOTP (.counter) / TOTP (.timer)
│   │   ├── SupportedHashAlgorithm.swift  # SHA1, SHA256, SHA512
│   │   ├── OTPError.swift            # Error types
│   │   ├── IssuerStrategy.swift      # URI issuer parsing strategies
│   │   └── Key.swift                 # CodingKey for URI parsing
│   ├── Generator.swift               # Concrete Generator struct
│   └── Password.swift                # Concrete Password struct
├── Tests/THOTPTests/
│   └── AllTests.swift                # All test cases (31 tests)
├── Package.swift                     # Swift Package Manager manifest
├── THOTP.podspec                     # CocoaPods spec
└── CODEOWNERS                        # @ericlewis
```

## Build Commands

```bash
# Build the library
swift build

# Run all tests
swift test

# Build for a specific platform (example: macOS)
swift build -Xswiftc "-sdk" -Xswiftc "$(xcrun --sdk macosx --show-sdk-path)"
```

## Dependencies

| Package | Purpose |
|---------|---------|
| [URL-QueryItem](https://github.com/ericlewis/URL-QueryItem) ^1.0.0 | URI query parameter parsing for `otpauth://` URIs |
| [Base32](https://github.com/norio-nomura/Base32) ^0.7.0 | Base32 encoding/decoding for OTP secrets |
| CryptoKit (Apple framework) | HMAC computation with SHA1, SHA256, SHA512 |

## Architecture

The library uses **protocol-oriented design**:

1. **`PasswordProtocol`** - Defines OTP password metadata (name, issuer, image, generator). Concrete type: `Password` (struct).
2. **`GeneratorProtocol`** - Defines OTP generation (secret, digits, algorithm, hash). Concrete type: `Generator` (struct).

Default implementations live in protocol extensions under `Extensions/`. This keeps protocol definitions clean and groups behavior by feature (URL serialization, generation, validation, equality).

### OTP Generation Flow

1. Calculate counter from time (TOTP) or use explicit counter (HOTP)
2. Compute HMAC using secret + counter with the selected hash algorithm
3. Truncate HMAC using dynamic offset to 4 bytes
4. Convert to decimal, modulo 10^digits, and left-pad with zeros

### Key Types

- **`GeneratorAlgorithm`** - `.timer(period:)` for TOTP, `.counter(_:)` for HOTP
- **`SupportedHashAlgorithm`** - `.sha1`, `.sha256`, `.sha512`
- **`OTPError`** - `.invalidDigits`, `.invalidPeriod`, `.invalidTime`, `.invalidURL`
- **`IssuerStrategy`** - `.default`, `.nameFirst`, `.queryFirst`, `.custom(closure)`

## Code Conventions

- **File naming:** Protocol extensions use `ProtocolName+Feature.swift`
- **Organization:** Group by type: Protocols, Extensions, Enums, then concrete types at root
- **Platform availability:** All public APIs annotated with `@available(iOS 13.0, OSX 10.15, watchOS 6.0, tvOS 13.0, *)`
- **Error handling:** Use `throws` with typed `OTPError` cases; guard statements for validation
- **Naming:** PascalCase for types, camelCase for properties/functions, camelCase for enum cases
- **Structs over classes:** All concrete types are structs (value semantics)
- **Access control:** Protocols and concrete types are public; internal helpers stay internal
- **Documentation:** Use `///` doc comments on public APIs

## Testing

- **Framework:** XCTest
- **Test file:** `Tests/THOTPTests/AllTests.swift` (single file, 31 test cases)
- **Patterns:** Direct construction of `Password`/`Generator` objects with assertions
- **Coverage areas:** TOTP generation (SHA1/256/512), HOTP generation (SHA1/256/512), validation errors, equality, URL serialization, URL parsing, issuer strategies, error handling
- **Determinism:** Timer-based tests use very large periods to produce stable results regardless of current time

## No CI/CD or Linting

There is no CI/CD pipeline, SwiftLint, or formatter configuration in this repository. Follow existing code style when making changes.
