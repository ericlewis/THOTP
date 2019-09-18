# THOTP

## TOTP & HOTP generator for iOS, tvOS, watchOS, and macOS

Pure Swift implementation of [time-based](https://en.wikipedia.org/wiki/Time-based_One-time_Password_algorithm) and [HMAC-based](https://en.wikipedia.org/wiki/HMAC-based_One-time_Password_algorithm) one-time password generators. Heavily inspired by the [OneTimePassword](https://github.com/mattrubin/OneTimePassword) library from [@mattrubin](https://github.com/mattrubin).

## Installation
`THOTP` can be installed via Swift Package Manager.

Supported platforms are iOS (13.0+), tvOS (13.0+), watchOS (6.0+), and macOS (10.15+).

### Swift Package Manager
The easiest integration is to use the built in package manager tools in Xcode 11.0+. You can also do it manually.

Add the following as a dependency to your Package.swift:
```swift
.package(url: "https://github.com/ericlewis/THOTP.git", .upToNextMajor(from: "1.0.0"))
```
After specifying "THOTP" as a dependency of the target in which you want to use it, run:
```bash
swift package update
```
