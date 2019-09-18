@available(iOS 13.0, OSX 10.15, watchOS 6.0, tvOS 13.0, *)
public extension PasswordProtocol {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.generator.secret == rhs.generator.secret && lhs.issuer == rhs.issuer && lhs.name == rhs.name && lhs.image == rhs.image
    }
}
