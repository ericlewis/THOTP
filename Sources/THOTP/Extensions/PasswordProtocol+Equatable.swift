@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
public extension PasswordProtocol {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name &&
        lhs.issuer == rhs.issuer &&
        lhs.image == rhs.image &&
        lhs.generator.secret == rhs.generator.secret &&
        lhs.generator.digits == rhs.generator.digits &&
        lhs.generator.hashAlgorithm == rhs.generator.hashAlgorithm &&
        lhs.generator.generatorAlgorithm.stringValue == rhs.generator.generatorAlgorithm.stringValue
    }
}
