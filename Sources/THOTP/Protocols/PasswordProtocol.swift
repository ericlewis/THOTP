import Foundation

@available(iOS 13.0, OSX 10.15, watchOS 6.0, tvOS 13.0, *)
public protocol PasswordProtocol: Equatable {
    var name: String {get}
    var issuer: String? {get}
    var image: URL? {get}
    var generator: GeneratorProtocol {get}
    var currentPassword: String? {get}
}
