import Foundation

/// A object for generating time-based & HMAC-based one-time passwords
///
/// ## Supported Generators
/// Extending this would require work around making the Generators & Hash functions extensible
/// Delta has a good example of this in action.
/// - Time-based
/// - HMAC-based
@available(iOS 13.0, OSX 10.15, watchOS 6.0, tvOS 13.0, *)
public struct Generator: GeneratorProtocol {
    public var secret: Data
    public var digits: Int
    public var generatorAlgorithm: GeneratorAlgorithm
    public var hashAlgorithm: SupportedHashAlgorithm
    
    public init(type: GeneratorAlgorithm, hash: SupportedHashAlgorithm, secret: Data, digits: Int) throws {
        try Self.validateGeneratorAlgorithm(type)
        
        self.generatorAlgorithm = type
        self.secret = secret
        self.digits = digits
        self.hashAlgorithm = hash
    }
}
