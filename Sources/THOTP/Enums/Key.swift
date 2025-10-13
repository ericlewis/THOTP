import Foundation

/// A type that represents the query item keys used for decoding URIs as specified by [this](https://github.com/google/google-authenticator/wiki/Key-Uri-Format) document.
@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
public enum Key: String, CodingKey, Sendable {
    case issuer
    case image
    case secret
    case digits
    case algorithm
    case period
    case counter
}
