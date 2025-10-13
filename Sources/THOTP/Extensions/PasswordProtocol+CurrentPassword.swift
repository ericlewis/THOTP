import Foundation

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
public extension PasswordProtocol {
    var currentPassword: String? {
        try? generator.generate(with: Date())
    }
}
