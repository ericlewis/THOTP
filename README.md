<p align="center">
    <a href="https://app.bitrise.io/app/a63b657c1a6f5d86#/builds">
        <img src="https://app.bitrise.io/app/a63b657c1a6f5d86.svg?token=g7-9vCfpqt8mp52OulTckw&branch=master" alt="Build Status">
    </a>
    <a href="https://github.com/ericlewis/THOTP/releases">
        <img src="https://img.shields.io/badge/version-1.0.0-blue.svg"
        alt="Version: 1.0.0">
    </a>
    <a href="https://github.com/piknotech/SFSafeSymbols/blob/stable/LICENSE.md">
        <img src="https://img.shields.io/badge/license-MIT-lightgrey.svg" alt="License: MIT">
    </a>
    <a href="#">
        <img src="https://img.shields.io/badge/swift-5.1-FFAC45.svg" alt="Swift: 5.1">
    </a>
    <a href="#">
    <img src="https://img.shields.io/badge/Platforms-iOS%20|%20tvOS%20|%20watchOS|%20macOS-purple.svg"
        alt="Platforms: iOS – tvOS – watchOS - macOS">
    </a>
    <a href="https://github.com/apple/swift-package-manager">
        <img src="https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg" alt="SwiftPM: Compatible">
    </a>
</p>

<p align="center">
    <a href="#installation">Installation</a>
  • <a href="#license">License</a>
  • <a href="https://github.com/ericlewis/THOTP/issues">Issues</a>
  • <a href="https://github.com/ericlewis/THOTP/pulls">Pull Requests</a>
</p>

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
After specifying `THOTP` as a dependency of the target in which you want to use it, run:
```bash
swift package update
```

## License
This library is released under the [MIT License](http://opensource.org/licenses/MIT). See [LICENSE.md](https://github.com/ericlewis/THOTP/blob/master/LICENSE.md) for details.
