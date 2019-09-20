import Foundation

/// A type that represents the query item keys used for decoding URIs as specified by [this](https://github.com/google/google-authenticator/wiki/Key-Uri-Format) document.
@available(iOS 13.0, OSX 10.15, watchOS 6.0, tvOS 13.0, *)
public enum Key: CodingKey {
    case 
    issuer, 
    image, 
    secret, 
    digits, 
    algorithm, 
    period,
    counter
}
