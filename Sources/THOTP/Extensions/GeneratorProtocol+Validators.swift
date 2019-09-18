import Foundation

@available(iOS 13.0, OSX 10.15, watchOS 6.0, tvOS 13.0, *)
public extension GeneratorProtocol {
    static func validateDigits(_ digits: Int) throws {
        guard (6...8).contains(digits) else {
            throw OTPError.invalidDigits
        }
    }
    
    static func validateGeneratorAlgorithm(_ generatorAlgorithm: GeneratorAlgorithm) throws {
        switch generatorAlgorithm {
        case .counter:
            return
        case .timer(let period):
            try validatePeriod(period)
        }
    }
    
    static func validatePeriod(_ period: TimeInterval) throws {
        guard period > 0 else {
            throw OTPError.invalidPeriod
        }
    }
    
    static func validateTime(_ timeSinceEpoch: TimeInterval) throws {
        guard timeSinceEpoch >= 0 else {
            throw OTPError.invalidTime
        }
    }
}
