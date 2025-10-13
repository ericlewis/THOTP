import Foundation

/// A type that represents the query item keys used for decoding URIs as specified by [this](https://github.com/google/google-authenticator/wiki/Key-Uri-Format) document.
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, *)
public enum Key: String, CodingKey, Sendable, BitwiseCopyable {
    case issuer
    case image
    case secret
    case digits
    case algorithm
    case period
    case counter
}
