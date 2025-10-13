import Foundation

/// A object for the metadata surrounding time-based & HMAC-based one-time passwords
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, *)
public struct Password: PasswordProtocol, Sendable {
    public var name: String
    public var issuer: String?
    public var image: URL?
    public var generator: any GeneratorProtocol

    public init(name: String, issuer: String? = nil, image: URL? = nil, generator: any GeneratorProtocol) {
        self.name = name
        self.issuer = issuer
        self.image = image
        self.generator = generator
    }
}
