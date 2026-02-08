# Test Coverage Analysis: THOTP

## Overview

THOTP is a Swift library implementing TOTP (RFC 6238) and HOTP (RFC 4226) one-time password generation. The current test suite lives in a single file (`Tests/THOTPTests/AllTests.swift`) containing 33 test methods.

This document catalogs what is currently tested, identifies gaps, and proposes specific areas for improvement ranked by priority.

---

## Current Coverage Summary

| Area | Status | Notes |
|------|--------|-------|
| TOTP generation (SHA1/256/512) | Partial | Uses trivial secrets, no RFC test vectors |
| HOTP generation (SHA1/256/512) | Partial | Only counter=1 tested |
| Validator: invalid period | Covered | Negative period throws |
| Validator: invalid digits | Partial | Only out-of-range; no boundary testing |
| Validator: invalid time | Covered | `Date.distantPast` throws |
| Equatable | Partial | Only secret and name differences |
| `absoluteURL` generation | Covered | Timer, counter, all-attributes variants |
| URL parsing (happy path) | Covered | Timer/counter with all/some params |
| URL parsing (error cases) | Covered | Invalid type, missing secret, invalid counter |
| Issuer strategies | Covered | default, nameFirst, queryFirst, custom |
| `generate(with:)` direct calls | Minimal | Only one test, and only for the error path |
| 7 and 8-digit codes | Not tested | |
| RFC 6238 test vectors | Not tested | |
| URL round-trip (encode -> decode) | Not tested | |
| `SupportedHashAlgorithm.length` | Not tested | |
| `GeneratorAlgorithm.stringValue` | Not tested | |

---

## Proposed Improvements (by priority)

### 1. RFC 6238 / RFC 4226 Test Vectors (High Priority)

**Why:** This is a cryptographic library. Correctness against the standard is paramount. The current tests use empty or trivial secrets with enormous periods, making the generated codes essentially static. None of the tests verify output against the official test vectors published in RFC 6238 Appendix B and RFC 4226 Appendix D.

**What to add:**
- TOTP tests using the RFC 6238 reference secret (`12345678901234567890`) at specific Unix timestamps (59, 1111111109, 1111111111, 1234567890, 2000000000, 20000000000) for SHA1, SHA256, and SHA512
- HOTP tests using the RFC 4226 reference secret at counters 0-9 for SHA1
- These tests should call `generate(with:)` with a fixed `Date` to produce deterministic, verifiable results

**Impact:** Validates that the core HMAC + dynamic truncation implementation is correct per the RFCs.

---

### 2. Direct `generate(with:)` Tests with Fixed Dates (High Priority)

**Why:** Nearly every generation test goes through `currentPassword`, which calls `generate(with: Date())`. This makes tests non-deterministic -- they rely on astronomically large periods to avoid time-sensitivity. Only one test calls `generate(with:)` directly, and solely to test the error path.

**What to add:**
- Tests calling `generate(with: specificDate)` for both TOTP and HOTP
- Tests with realistic periods (30s, 60s) at known timestamps
- Verify that two calls with the same date produce the same output
- Verify that two calls in different time windows produce different output

**Impact:** Makes generation tests deterministic and verifiable.

---

### 3. Digit Count Boundary Testing (Medium Priority)

**Why:** Valid digit counts are 6, 7, and 8 per the RFC. All 33 tests use 6 digits. The digit validation only has one test for an out-of-range value.

**What to add:**
- Generation tests with `digits: 7` and `digits: 8` verifying correct output length
- Boundary validation tests: digits=5 throws `invalidDigits`, digits=6 succeeds, digits=8 succeeds, digits=9 throws `invalidDigits`
- Verify the output is correctly zero-padded for each digit count

**Impact:** Ensures the full valid range works and boundaries are enforced.

---

### 4. Counter Value Edge Cases (Medium Priority)

**Why:** Only `counter: 1` is tested for HOTP. The counter is a `UInt64`, allowing a vast range.

**What to add:**
- Counter `0` (first use)
- Large counter values (e.g., `UInt64.max`, `999999`)
- Sequential counters producing different codes (counter=0, 1, 2, ...)

**Impact:** Validates HOTP correctness across the counter range.

---

### 5. URL Round-Trip Tests (Medium Priority)

**Why:** There are tests for URL parsing and tests for `absoluteURL` generation, but no test that verifies `Password(url: password.absoluteURL) == password`. This is the most important invariant of the URL code.

**What to add:**
- Create a `Password` with various configurations (timer/counter, all hash algorithms, with/without issuer, with/without image), generate its `absoluteURL`, parse it back, and assert equality
- Test with special characters in name and issuer (spaces, `@`, unicode)

**Impact:** Guarantees encoding and decoding are symmetric.

---

### 6. Equatable Completeness (Medium Priority)

**Why:** The `==` implementation (`PasswordProtocol+Equatable.swift:3-4`) compares `secret`, `issuer`, `name`, and `image` -- but does **not** compare `digits`, `generatorAlgorithm`, or `hashAlgorithm`. This means two Passwords with the same secret/name/issuer/image but different hash algorithms or digit counts are considered equal. The test suite only varies `secret` and `name`.

**What to add:**
- Test that passwords with different `issuer` values are not equal
- Test that passwords with different `image` values are not equal
- Test (or document) the current behavior where different `digits`, `hashAlgorithm`, or `generatorAlgorithm` values still compare as equal -- this may be an intentional design decision or a bug worth addressing

**Impact:** Documents and validates equality semantics; may surface a latent bug.

---

### 7. URL Parsing Edge Cases (Low Priority)

**Why:** The URL parsing covers the main happy and error paths, but several edge cases are missing.

**What to add:**
- SHA1 and SHA256 in URL (current URL tests only use SHA512)
- Unknown/extra query parameters are ignored gracefully
- Name with special characters (spaces, unicode, `%`-encoded)
- Empty path component (`otpauth://totp/`)
- HOTP URL with an extra `period` param (should be ignored)
- TOTP URL with an extra `counter` param (should be ignored)
- Case sensitivity: `SHA1` vs `sha1` vs `Sha1` in the algorithm param

**Impact:** Hardens URL parsing against real-world edge cases.

---

### 8. IssuerStrategy Edge Cases (Low Priority)

**Why:** The four strategies are tested, but only when both issuer sources have values. Several nil combinations are untested.

**What to add:**
- `.nameFirst` when `issuerSplittedFromName` is nil (should return nil)
- `.queryFirst` when `issuerFromQueryItems` is nil (should return nil)
- `.default` when both are nil (should return nil)
- `.custom` closure that throws an error

**Impact:** Ensures strategy behavior is correct for all input combinations.

---

### 9. `SupportedHashAlgorithm` and `GeneratorAlgorithm` Unit Tests (Low Priority)

**Why:** These enums have computed properties (`length`, `stringValue`, `value(for:)`) that are tested only indirectly through integration tests.

**What to add:**
- `SupportedHashAlgorithm.length` returns correct byte counts (20 for SHA1, 32 for SHA256, 64 for SHA512)
- `GeneratorAlgorithm.stringValue` returns `"hotp"` and `"totp"`
- `GeneratorAlgorithm.value(for:)` returns correct counter for known dates

**Impact:** Isolates enum logic for easier debugging.

---

### 10. Test Organization (Low Priority)

**Why:** All 33 tests are in a single `AllTests` class. As coverage grows, this will become harder to maintain.

**What to add:**
- Split into focused test files: `GeneratorTests.swift`, `PasswordURLTests.swift`, `ValidatorTests.swift`, `EquatableTests.swift`, `IssuerStrategyTests.swift`
- Group related tests using `// MARK:` comments or separate classes

**Impact:** Improves maintainability and makes it easier to identify which area failed.

---

## Summary Priority Matrix

| Priority | Area | Estimated Tests to Add |
|----------|------|----------------------|
| High | RFC test vectors | ~20 |
| High | Direct `generate(with:)` tests | ~8 |
| Medium | Digit count boundaries | ~6 |
| Medium | Counter value edge cases | ~5 |
| Medium | URL round-trip | ~6 |
| Medium | Equatable completeness | ~5 |
| Low | URL parsing edge cases | ~8 |
| Low | IssuerStrategy edge cases | ~4 |
| Low | Enum unit tests | ~6 |
| Low | Test organization | Restructure |
| | **Total** | **~68 new tests** |
