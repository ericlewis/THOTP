@available(iOS 13.0, OSX 10.15, watchOS 6.0, tvOS 13.0, *)
enum OTPError: Error {
    case invalidDigits, invalidPeriod, invalidTime, invalidURL
}
