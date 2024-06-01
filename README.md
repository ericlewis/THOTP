<p align="center">
    <a href="#">
        <img src="https://repository-images.githubusercontent.com/209410933/b4103000-dae0-11e9-9d44-c8a9d88f57b4" alt="THOTP Logo">
    </a> 
<p align="center">
    <a href="https://codecov.io/gh/ericlewis/THOTP">
        <img src="https://codecov.io/gh/ericlewis/THOTP/branch/master/graph/badge.svg" />
    </a>
    <a href="https://ericlewis.github.io/THOTP/docs/">
        <img src="https://ericlewis.github.io/THOTP/docs/badge.svg" />
    </a>
    <a href="https://github.com/piknotech/SFSafeSymbols/blob/stable/LICENSE.md">
        <img src="https://img.shields.io/badge/license-MIT-lightgrey.svg" alt="License: MIT" />
    </a>
    <a href="#">
        <img src="https://img.shields.io/badge/swift-5.1-FFAC45.svg" alt="Swift: 5.1" />
    </a>
    <a href="https://github.com/apple/swift-package-manager">
        <img src="https://img.shields.io/badge/SwiftPM-✓-brightgreen.svg" alt="SwiftPM: Compatible">
    </a>
    <a href="#">
    <img src="https://img.shields.io/badge/platforms-iOS%20|%20tvOS%20|%20watchOS%20|%20macOS-purple.svg"
        alt="Platforms: iOS – tvOS – watchOS - macOS">
    </a>
</p>

<p align="center">
    <a href="#installation">Installation</a>
  • <a href="#usage">Usage</a>
  • <a href="https://ericlewis.github.io/THOTP/docs/">Documentation</a>
  • <a href="#license">License</a>
  • <a href="https://github.com/ericlewis/THOTP/issues">Issues</a>
  • <a href="https://github.com/ericlewis/THOTP/pulls">Pull Requests</a>
</p>

### TOTP & HOTP generator for iOS, tvOS, watchOS, and macOS

Pure Swift implementation of [time-based](https://en.wikipedia.org/wiki/Time-based_One-time_Password_algorithm) and [HMAC-based](https://en.wikipedia.org/wiki/HMAC-based_One-time_Password_algorithm) one-time password generators. Heavily inspired by the [OneTimePassword](https://github.com/mattrubin/OneTimePassword) library from [@mattrubin](https://github.com/mattrubin). Protocol based design, so you won't find any subclasses here.

## Installation

`THOTP` can be installed via Swift Package Manager.

Supported platforms are iOS (13.0+), tvOS (13.0+), watchOS (6.0+), and macOS (10.15+).

### Swift Package Manager

The easiest integration is to use the built in package manager tools in Xcode 11.0+. You can also do it manually.

Add the following as a dependency to your Package.swift:

```swift
.package(url: "https://github.com/ericlewis/THOTP.git", .upToNextMajor(from: "1.0.0"))
```

After specifying `THOTP` as a dependency of the target in which you want to use it, run:

```bash
swift package update
```

## Usage

By default, this includes basic concrete types for Password & Generators. If you are interested in persistence, there are a couple of options to choose from:

- Implement `PasswordProtocol` with your own concrete type, such as `NSManagedObject`
- Use [Valet-THOTP](https://github.com/ericlewis/Valet-THOTP), which adds extensions + a new concrete type for easily persisting using [Valet](https://github.com/square/Valet)

### Basic

The simplest usage is to parse a URL. `THOTP` is compatible with [Google Authenticator's URI Scheme](https://github.com/google/google-authenticator/wiki/Key-Uri-Format).

```swift
let password = try? Password(url: URL(string: "otpauth://totp/test?secret=GEZDGNBV")!)
print(password.currentPassword) // 123321
```

## Documentation

Docs are generated with [jazzy](https://github.com/realm/jazzy) & can be found [here](https://ericlewis.github.io/THOTP/docs/). The process is currently manual, so it's possible for documentation to be out of date. Tests are a great way to see how to use this library.

## License

This library is released under the [MIT License](http://opensource.org/licenses/MIT). See [LICENSE](https://github.com/ericlewis/THOTP/blob/master/LICENSE) for details.
