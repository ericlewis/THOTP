import Foundation

/// A type that can represent a generator for a given type of one-time password
///
/// This object is used for validation as well as storage for the actual algorithm generation data
@available(iOS 13.0, OSX 10.15, watchOS 6.0, tvOS 13.0, *)
public protocol GeneratorProtocol {
    
    /// Validates the number of digits to generate
    ///
    /// the suggested number of digits is 6-8, as stated by [RFC6238](https://tools.ietf.org/html/rfc6238).
    ///
    /// - Parameter digits: The length of the code to be generated
    static func validateDigits(_ digits: Int) throws
    
    /// Ensure that the given generation algorithm is valid
    ///
    /// - Parameter generatorAlgorithm: The generator algorithm to verify
    static func validateGeneratorAlgorithm(_ generatorAlgorithm: GeneratorAlgorithm) throws
    
    /// Validate that the requested time to generate a token against is not before the `UNIX` reference time
    ///
    /// - Parameter timeSinceEpoch: Time since UNIX reference in seconds
    static func validateTime(_ timeSinceEpoch: TimeInterval) throws
    
    /// Validate often the token should change (should be a positive number)
    ///
    /// - Parameter period: Duration of time in seconds
    static func validatePeriod(_ period: TimeInterval) throws
    
    /// A `Base32` shared secret
    var secret: Data {get}
    
    /// The length of the code to be generated
    var digits: Int {get}
    
    /// Generator algorithm being used
    var generatorAlgorithm: GeneratorAlgorithm {get}
    
    /// Hash function being used
    var hashAlgorithm: SupportedHashAlgorithm {get}
    
    /// Creates a one-time password
    /// - Parameter date: Seed date to generate from, must be in the future
    func generate(with date: Date) throws -> String    
}
