@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, *)
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
