import Foundation

/// The available generator algorithms used for password generation
///
/// Most use a variation of the counter approach
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, *)
public enum GeneratorAlgorithm: Sendable, BitwiseCopyable {
    case counter(UInt64)
    case timer(period: TimeInterval)

    /// Default period for TOTP tokens (30 seconds)
    public static let defaultPeriod: TimeInterval = 30

    /// The string value of the given algorithm, used for parsing URLs typically
    public var stringValue: String {
        switch self {
        case .counter:
            return "hotp"
        case .timer:
            return "totp"
        }
    }

    /// The counter value, depending on algorithm chosen
    func value(for time: borrowing Date) throws(OTPError) -> UInt64 {
        switch self {
        case .counter(let counter):
            return counter
        case .timer(let period):
            let timeSinceEpoch = time.timeIntervalSince1970
            try Generator.validateTime(timeSinceEpoch)
            try Generator.validatePeriod(period)
            return UInt64(timeSinceEpoch / period)
        }
    }
}
