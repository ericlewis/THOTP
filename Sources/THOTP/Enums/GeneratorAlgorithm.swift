import Foundation

@available(iOS 13.0, OSX 10.15, watchOS 6.0, tvOS 13.0, *)
public enum GeneratorAlgorithm {
    case counter(UInt64), timer(period: TimeInterval)
    
    var stringValue: String {
        switch self {
        case .counter(_):
            return "hotp"
        case .timer(_):
            return "totp"
        }
    }
    
    func value(for time: Date) throws -> UInt64 {
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
