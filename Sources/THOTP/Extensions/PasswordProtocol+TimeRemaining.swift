import Foundation

@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, *)
public extension PasswordProtocol {
    /// Time remaining until the current TOTP password expires
    /// Returns nil for HOTP (counter-based) passwords
    var timeRemaining: TimeInterval? {
        guard case .timer(let period) = generator.generatorAlgorithm else {
            return nil
        }

        let now = Date().timeIntervalSince1970
        let timeInPeriod = now.truncatingRemainder(dividingBy: period)
        return period - timeInPeriod
    }

    /// Progress of the current TOTP password period (0.0 to 1.0)
    /// Returns nil for HOTP (counter-based) passwords
    var passwordProgress: Double? {
        guard case .timer(let period) = generator.generatorAlgorithm else {
            return nil
        }

        let now = Date().timeIntervalSince1970
        let timeInPeriod = now.truncatingRemainder(dividingBy: period)
        return timeInPeriod / period
    }
}
