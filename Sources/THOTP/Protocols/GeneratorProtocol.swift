import Foundation

@available(iOS 13.0, OSX 10.15, watchOS 6.0, tvOS 13.0, *)
public protocol GeneratorProtocol {
    static func validateDigits(_ digits: Int) throws
    static func validateGeneratorAlgorithm(_ algorithm: GeneratorAlgorithm) throws
    static func validateTime(_ timeSinceEpoch: TimeInterval) throws
    static func validatePeriod(_ period: TimeInterval) throws
    
    var secret: Data {get}
    var digits: Int {get}
    var generatorAlgorithm: GeneratorAlgorithm {get}
    var hashAlgorithm: SupportedHashAlgorithm {get}
    
    func generate(with date: Date) throws -> String    
}
