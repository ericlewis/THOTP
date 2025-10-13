import Foundation

@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, *)
public extension PasswordProtocol {
    var currentPassword: String? {
        try? generator.generate(with: Date())
    }
}
