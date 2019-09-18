import Foundation

@available(iOS 13.0, OSX 10.15, watchOS 6.0, tvOS 13.0, *)
public extension PasswordProtocol {
    var currentPassword: String? {
        try? generator.generate(with: Date())
    }
}
