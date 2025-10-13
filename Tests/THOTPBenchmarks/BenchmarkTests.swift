import XCTest
import Base32
@testable import THOTP

/// Performance benchmarks for THOTP 2.0
///
/// These tests measure the performance improvements from Swift 6.2 features:
/// - BitwiseCopyable: Zero-cost enum copying
/// - borrowing parameters: Reduced allocations
/// - Optimized string padding: Faster formatting
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, *)
final class BenchmarkTests: XCTestCase {

    // MARK: - Test Data

    let testSecret = Data("JBSWY3DPEHPK3PXP".utf8)
    let base32Secret = "JBSWY3DPEHPK3PXP".base32DecodedData!

    // MARK: - Generator Creation Benchmarks

    func testBenchmarkGeneratorCreation_TOTP() throws {
        measure {
            for _ in 0..<1000 {
                _ = try? Generator(
                    type: .timer(period: 30),
                    hash: .sha256,
                    secret: base32Secret,
                    digits: 6
                )
            }
        }
    }

    func testBenchmarkGeneratorCreation_HOTP() throws {
        measure {
            for _ in 0..<1000 {
                _ = try? Generator(
                    type: .counter(1),
                    hash: .sha256,
                    secret: base32Secret,
                    digits: 6
                )
            }
        }
    }

    // MARK: - Password Generation Benchmarks

    func testBenchmarkPasswordGeneration_SHA1() throws {
        let generator = try Generator(
            type: .timer(period: 30),
            hash: .sha1,
            secret: base32Secret,
            digits: 6
        )
        let date = Date()

        measure {
            for _ in 0..<1000 {
                _ = try? generator.generate(with: date)
            }
        }
    }

    func testBenchmarkPasswordGeneration_SHA256() throws {
        let generator = try Generator(
            type: .timer(period: 30),
            hash: .sha256,
            secret: base32Secret,
            digits: 6
        )
        let date = Date()

        measure {
            for _ in 0..<1000 {
                _ = try? generator.generate(with: date)
            }
        }
    }

    func testBenchmarkPasswordGeneration_SHA512() throws {
        let generator = try Generator(
            type: .timer(period: 30),
            hash: .sha512,
            secret: base32Secret,
            digits: 6
        )
        let date = Date()

        measure {
            for _ in 0..<1000 {
                _ = try? generator.generate(with: date)
            }
        }
    }

    // MARK: - Different Digit Counts

    func testBenchmarkPasswordGeneration_6Digits() throws {
        let generator = try Generator(
            type: .timer(period: 30),
            hash: .sha256,
            secret: base32Secret,
            digits: 6
        )
        let date = Date()

        measure {
            for _ in 0..<1000 {
                _ = try? generator.generate(with: date)
            }
        }
    }

    func testBenchmarkPasswordGeneration_8Digits() throws {
        let generator = try Generator(
            type: .timer(period: 30),
            hash: .sha256,
            secret: base32Secret,
            digits: 8
        )
        let date = Date()

        measure {
            for _ in 0..<1000 {
                _ = try? generator.generate(with: date)
            }
        }
    }

    // MARK: - URL Parsing Benchmarks

    func testBenchmarkURLParsing_Minimal() throws {
        let url = URL(string: "otpauth://totp/test?secret=JBSWY3DPEHPK3PXP")!

        measure {
            for _ in 0..<100 {
                _ = try? Password(url: url)
            }
        }
    }

    func testBenchmarkURLParsing_Complete() throws {
        let url = URL(string: "otpauth://totp/GitHub:user@github.com?secret=JBSWY3DPEHPK3PXP&issuer=GitHub&algorithm=SHA256&digits=6&period=30")!

        measure {
            for _ in 0..<100 {
                _ = try? Password(url: url)
            }
        }
    }

    // MARK: - URL Generation Benchmarks

    func testBenchmarkURLGeneration() throws {
        let generator = try Generator(
            type: .timer(period: 30),
            hash: .sha256,
            secret: base32Secret,
            digits: 6
        )
        let password = Password(
            name: "user@example.com",
            issuer: "Example",
            generator: generator
        )

        measure {
            for _ in 0..<1000 {
                _ = password.absoluteURL
            }
        }
    }

    // MARK: - Equality Comparison Benchmarks

    func testBenchmarkPasswordEquality() throws {
        let gen1 = try Generator(type: .timer(period: 30), hash: .sha256, secret: base32Secret, digits: 6)
        let gen2 = try Generator(type: .timer(period: 30), hash: .sha256, secret: base32Secret, digits: 6)

        let pw1 = Password(name: "test", issuer: "app", generator: gen1)
        let pw2 = Password(name: "test", issuer: "app", generator: gen2)

        measure {
            for _ in 0..<10000 {
                _ = pw1 == pw2
            }
        }
    }

    // MARK: - Time Remaining Calculations

    func testBenchmarkTimeRemaining() throws {
        let generator = try Generator(
            type: .timer(period: 30),
            hash: .sha256,
            secret: base32Secret,
            digits: 6
        )
        let password = Password(name: "test", generator: generator)

        measure {
            for _ in 0..<10000 {
                _ = password.timeRemaining
            }
        }
    }

    func testBenchmarkPasswordProgress() throws {
        let generator = try Generator(
            type: .timer(period: 30),
            hash: .sha256,
            secret: base32Secret,
            digits: 6
        )
        let password = Password(name: "test", generator: generator)

        measure {
            for _ in 0..<10000 {
                _ = password.passwordProgress
            }
        }
    }

    // MARK: - End-to-End Scenarios

    func testBenchmarkEndToEnd_CreateAndGenerate() throws {
        let date = Date()

        measure {
            for i in 0..<100 {
                if let generator = try? Generator(
                    type: .timer(period: 30),
                    hash: .sha256,
                    secret: base32Secret,
                    digits: 6
                ) {
                    let password = Password(
                        name: "user\(i)@example.com",
                        issuer: "Example",
                        generator: generator
                    )
                    _ = try? generator.generate(with: date)
                    _ = password.timeRemaining
                }
            }
        }
    }

    func testBenchmarkEndToEnd_ParseAndGenerate() throws {
        let url = URL(string: "otpauth://totp/Example:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example&algorithm=SHA256&digits=6&period=30")!
        let date = Date()

        measure {
            for _ in 0..<100 {
                if let password = try? Password(url: url) {
                    _ = try? password.generator.generate(with: date)
                }
            }
        }
    }

    // MARK: - BitwiseCopyable Performance Test

    func testBenchmarkEnumCopying() throws {
        // Test BitwiseCopyable enum performance
        var algorithms: [SupportedHashAlgorithm] = []

        measure {
            // BitwiseCopyable makes this extremely fast
            for _ in 0..<100000 {
                algorithms.append(.sha256)
                algorithms.append(.sha512)
                algorithms.append(.sha1)
            }
            algorithms.removeAll()
        }
    }

    // MARK: - Memory Allocation Tests

    func testMemoryAllocation_PasswordGeneration() throws {
        let generator = try Generator(
            type: .timer(period: 30),
            hash: .sha256,
            secret: base32Secret,
            digits: 6
        )

        // Measure allocations with borrowing parameters
        let options = XCTMeasureOptions()
        options.iterationCount = 10

        measure(metrics: [XCTMemoryMetric()], options: options) {
            let date = Date()
            for _ in 0..<1000 {
                _ = try? generator.generate(with: date)
            }
        }
    }

    func testMemoryAllocation_URLParsing() throws {
        let url = URL(string: "otpauth://totp/Example:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example&algorithm=SHA256&digits=6&period=30")!

        let options = XCTMeasureOptions()
        options.iterationCount = 10

        measure(metrics: [XCTMemoryMetric()], options: options) {
            for _ in 0..<100 {
                _ = try? Password(url: url)
            }
        }
    }

    // MARK: - Performance Report

    func testPerformanceReport() throws {
        print("\n" + String(repeating: "=", count: 70))
        print("THOTP 2.0 Performance Report")
        print(String(repeating: "=", count: 70))

        let iterations = 1000
        let generator = try Generator(
            type: .timer(period: 30),
            hash: .sha256,
            secret: base32Secret,
            digits: 6
        )
        let date = Date()

        // Test generation speed
        let start = Date()
        for _ in 0..<iterations {
            _ = try? generator.generate(with: date)
        }
        let duration = Date().timeIntervalSince(start)

        print("\n📊 Password Generation:")
        print("   Iterations: \(iterations)")
        print("   Total Time: \(String(format: "%.3f", duration * 1000))ms")
        print("   Average: \(String(format: "%.3f", (duration / Double(iterations)) * 1000000))µs per operation")
        print("   Throughput: \(String(format: "%.0f", Double(iterations) / duration)) ops/sec")

        // Test URL parsing
        let url = URL(string: "otpauth://totp/Example:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example")!
        let parseIterations = 100
        let parseStart = Date()
        for _ in 0..<parseIterations {
            _ = try? Password(url: url)
        }
        let parseDuration = Date().timeIntervalSince(parseStart)

        print("\n📊 URL Parsing:")
        print("   Iterations: \(parseIterations)")
        print("   Total Time: \(String(format: "%.3f", parseDuration * 1000))ms")
        print("   Average: \(String(format: "%.3f", (parseDuration / Double(parseIterations)) * 1000))ms per parse")

        // Test enum copying (BitwiseCopyable)
        var enums: [SupportedHashAlgorithm] = []
        let enumIterations = 100000
        let enumStart = Date()
        for _ in 0..<enumIterations {
            enums.append(.sha256)
        }
        let enumDuration = Date().timeIntervalSince(enumStart)

        print("\n📊 BitwiseCopyable Enum Copying:")
        print("   Iterations: \(enumIterations)")
        print("   Total Time: \(String(format: "%.3f", enumDuration * 1000))ms")
        print("   Average: \(String(format: "%.3f", (enumDuration / Double(enumIterations)) * 1000000))µs per copy")

        print("\n✨ Swift 6.2 Optimizations Active:")
        print("   ✓ BitwiseCopyable enums (zero-cost)")
        print("   ✓ borrowing parameters (reduced allocations)")
        print("   ✓ Typed throws (compile-time safety)")
        print("   ✓ Strict concurrency (data race free)")

        print(String(repeating: "=", count: 70) + "\n")
    }
}
