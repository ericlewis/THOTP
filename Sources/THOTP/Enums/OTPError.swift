import Foundation

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
public enum OTPError: Error, Sendable, BitwiseCopyable {
    case invalidDigits
    case invalidPeriod
    case invalidTime
    case invalidURL
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
extension OTPError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidDigits:
            return "Invalid number of digits. Must be between 6 and 8."
        case .invalidPeriod:
            return "Invalid period. Must be greater than 0."
        case .invalidTime:
            return "Invalid time. Must be after UNIX epoch."
        case .invalidURL:
            return "Invalid OTP URL format."
        }
    }
}
