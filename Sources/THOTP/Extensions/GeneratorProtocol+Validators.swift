import Foundation

/// Supports counters & timers
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, *)
public extension GeneratorProtocol {
    static func validateDigits(_ digits: Int) throws(OTPError) {
        guard (6...8).contains(digits) else {
            throw OTPError.invalidDigits
        }
    }

    /// Counter's aren't validated, but the period must be greater than 0
    /// So we do validate that.
    static func validateGeneratorAlgorithm(_ generatorAlgorithm: GeneratorAlgorithm) throws(OTPError) {
        switch generatorAlgorithm {
        case .counter:
            return
        case .timer(let period):
            try validatePeriod(period)
        }
    }

    static func validatePeriod(_ period: TimeInterval) throws(OTPError) {
        guard period > 0 else {
            throw OTPError.invalidPeriod
        }
    }

    static func validateTime(_ timeSinceEpoch: TimeInterval) throws(OTPError) {
        guard timeSinceEpoch >= 0 else {
            throw OTPError.invalidTime
        }
    }
}
