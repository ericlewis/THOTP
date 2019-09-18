import Foundation

@available(iOS 13.0, OSX 10.15, watchOS 6.0, tvOS 13.0, *)
public struct Password: PasswordProtocol {
    public var name: String
    public var issuer: String?
    public var image: URL?
    public var generator: GeneratorProtocol
    
    public init(name: String, issuer: String? = nil, image: URL? = nil, generator: GeneratorProtocol) {
        self.name = name
        self.issuer = issuer
        self.image = image
        self.generator = generator
    }
}
