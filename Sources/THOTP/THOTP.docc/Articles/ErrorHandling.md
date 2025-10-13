# Error Handling

Handle errors gracefully with Swift 6.2's typed throws.

## Overview

THOTP uses typed throws (`throws(OTPError)`) for compile-time error safety. All errors are ``OTPError`` cases with helpful localized descriptions.

## Error Types

THOTP defines four error cases:

### Invalid Digits

Thrown when the digit count is not 6-8:

```swift
do {
    let generator = try Generator(
        type: .timer(period: 30),
        hash: .sha256,
        secret: secretData,
        digits: 3  // ❌ Too few!
    )
} catch OTPError.invalidDigits {
    // Error: "Invalid number of digits. Must be between 6 and 8."
    print("Please use 6-8 digits")
}
```

### Invalid Period

Thrown when the TOTP period is not positive:

```swift
do {
    let generator = try Generator(
        type: .timer(period: 0),  // ❌ Must be > 0
        hash: .sha256,
        secret: secretData,
        digits: 6
    )
} catch OTPError.invalidPeriod {
    // Error: "Invalid period. Must be greater than 0."
    print("Period must be positive")
}
```

### Invalid Time

Thrown when generating codes for dates before UNIX epoch:

```swift
do {
    let generator = try Generator(...)
    let veryOld = Date(timeIntervalSince1970: -1000)  // Before 1970
    let code = try generator.generate(with: veryOld)  // ❌
} catch OTPError.invalidTime {
    // Error: "Invalid time. Must be after UNIX epoch."
    print("Date must be after January 1, 1970")
}
```

### Invalid URL

Thrown when parsing malformed `otpauth://` URLs:

```swift
do {
    // Missing required 'secret' parameter
    let url = URL(string: "otpauth://totp/test")!
    let password = try Password(url: url)
} catch OTPError.invalidURL {
    // Error: "Invalid OTP URL format."
    print("URL is malformed or missing required parameters")
}
```

Common causes:
- Missing `secret` parameter
- Invalid `counter` value for HOTP
- Mismatched issuers (with default strategy)
- Malformed URL structure

## Typed Throws Benefits

### Compile-Time Safety

The compiler knows exactly what can be thrown:

```swift
func generateSecureCode() throws(OTPError) -> String {
    let generator = try Generator(...)  // Can only throw OTPError
    return try generator.generate(with: Date())
}
```

### Exhaustive Matching

Handle all cases with compile-time verification:

```swift
do {
    let password = try Password(url: url)
} catch OTPError.invalidDigits {
    // Handle invalid digits
} catch OTPError.invalidPeriod {
    // Handle invalid period
} catch OTPError.invalidTime {
    // Handle invalid time
} catch OTPError.invalidURL {
    // Handle invalid URL
}
// Compiler verifies all cases are handled
```

### Pattern Matching

Use pattern matching for specific errors:

```swift
do {
    let generator = try Generator(...)
} catch let error where error == .invalidDigits {
    print("Digit error: \(error.localizedDescription)")
} catch let error where error == .invalidPeriod {
    print("Period error: \(error.localizedDescription)")
} catch {
    print("Other error: \(error.localizedDescription)")
}
```

## Localized Error Messages

All errors conform to `LocalizedError` with helpful descriptions:

```swift
let error = OTPError.invalidDigits

print(error.localizedDescription)
// "Invalid number of digits. Must be between 6 and 8."
```

Use these in UI:

```swift
do {
    let generator = try Generator(...)
} catch {
    // Show user-friendly error message
    showAlert(title: "Error", message: error.localizedDescription)
}
```

## Validation Timing

THOTP validates inputs **early** to fail fast:

```swift
// ✅ Validation happens here (fails immediately)
let generator = try Generator(
    type: .timer(period: -10),  // Throws OTPError.invalidPeriod
    hash: .sha256,
    secret: secretData,
    digits: 6
)

// ✅ No validation needed here (already validated)
let code = try generator.generate(with: Date())
```

This design ensures:
- Errors are caught during initialization
- Generation is fast (no repeated validation)
- No surprising errors during code generation

## Error Recovery

### Retry with Valid Input

```swift
func createGenerator(period: TimeInterval) throws(OTPError) -> Generator {
    do {
        return try Generator(
            type: .timer(period: period),
            hash: .sha256,
            secret: secretData,
            digits: 6
        )
    } catch OTPError.invalidPeriod {
        // Retry with default period
        return try Generator(
            type: .timer(period: 30),
            hash: .sha256,
            secret: secretData,
            digits: 6
        )
    }
}
```

### Fallback Values

```swift
func parsePassword(from url: URL) -> Password? {
    do {
        return try Password(url: url)
    } catch OTPError.invalidURL {
        // Try alternative parsing strategies
        return try? Password(url: url, issuerStrategy: .nameFirst)
    } catch {
        return nil
    }
}
```

### User Feedback

```swift
struct PasswordSetupView: View {
    @State private var errorMessage: String?

    func createPassword() {
        do {
            let generator = try Generator(...)
            let password = Password(...)
            savePassword(password)
        } catch let error as OTPError {
            errorMessage = error.localizedDescription
        }
    }

    var body: some View {
        // Show errorMessage to user
        if let error = errorMessage {
            Text(error).foregroundColor(.red)
        }
    }
}
```

## Testing Error Cases

Write tests for all error scenarios:

```swift
func testInvalidDigits() throws {
    XCTAssertThrowsError(
        try Generator(type: .counter(1), hash: .sha256, secret: secret, digits: 3)
    ) { error in
        XCTAssertEqual(error as? OTPError, .invalidDigits)
    }
}

func testInvalidURL() throws {
    let url = URL(string: "otpauth://totp/test")!  // Missing secret
    XCTAssertThrowsError(
        try Password(url: url)
    ) { error in
        XCTAssertEqual(error as? OTPError, .invalidURL)
        XCTAssertNotNil(error.localizedDescription)
    }
}
```

## Best Practices

1. **Catch specific cases**: Use pattern matching for different error types
2. **Show localized messages**: Use `error.localizedDescription` in UI
3. **Validate early**: Let THOTP validate during initialization
4. **Test error paths**: Ensure error handling works correctly
5. **Provide fallbacks**: Have sensible defaults when possible
6. **Log errors**: Record errors for debugging and monitoring

## See Also

- ``OTPError``
- ``Generator/init(type:hash:secret:digits:)``
- ``Password/init(url:)``
- ``Password/init(url:issuerStrategy:)``
