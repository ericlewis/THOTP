import Foundation

/// A object for generating time-based & HMAC-based one-time passwords
///
/// ## Supported Generators
/// - Time-based (TOTP)
/// - HMAC-based (HOTP)
@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
public struct Generator: GeneratorProtocol, Sendable {
    /// Default number of digits in generated passwords (RFC 6238 recommendation)
    public static let defaultDigits: Int = 6

    public var secret: Data
    public var digits: Int
    public var generatorAlgorithm: GeneratorAlgorithm
    public var hashAlgorithm: SupportedHashAlgorithm

    public init(type: GeneratorAlgorithm, hash: SupportedHashAlgorithm, secret: Data, digits: Int) throws(OTPError) {
        try Self.validateGeneratorAlgorithm(type)
        try Self.validateDigits(digits)

        self.generatorAlgorithm = type
        self.secret = secret
        self.digits = digits
        self.hashAlgorithm = hash
    }
}
