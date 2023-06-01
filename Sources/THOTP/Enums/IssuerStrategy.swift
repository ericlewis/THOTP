import Foundation

/// The strategy gives the freedom to decide how the `issuer` value will be grabbed from the URL.
/// `Default` is recommended and the other options enable the API to cover all use cases by including `custom` option.
@available(iOS 13.0, OSX 10.15, watchOS 6.0, tvOS 13.0, *)
public enum IssuerStrategy {
    
    case `default`
    case nameFirst
    case queryFirst
    case custom((_ issuerSplittedFromName: String?, _ issuerFromQueryItems: String?) throws -> String?)
    
    public func grabIssuer(issuerSplittedFromName: String?, issuerFromQueryItems: String?) throws -> String? {
        switch self {
        case .default:
            /// The issuer parameter is a string value indicating the provider or service this account is associated with, URL-encoded according to RFC 3986.
            /// If the issuer parameter is absent, issuer information may be taken from the issuer prefix of the label.
            /// If both issuer parameter and issuer label prefix are present, they should be equal.
            /// Source: https://github.com/google/google-authenticator/wiki/Key-Uri-Format#issuer
            switch (issuerSplittedFromName, issuerFromQueryItems) {
            case (.some(let issuerSplittedFromName), .some(let issuerFromQueryItems)):
                guard issuerSplittedFromName == issuerFromQueryItems else {
                    throw OTPError.invalidURL
                }
                return issuerSplittedFromName
            case (.some(let issuerSplittedFromName), .none):
                return issuerSplittedFromName
            case (.none, .some(let issuerFromQueryItems)):
                return issuerFromQueryItems
            case (.none, .none):
                return nil
            }
        case .nameFirst:
            return issuerSplittedFromName
        case .queryFirst:
            return issuerFromQueryItems
        case .custom(let factory):
            return try factory(issuerSplittedFromName, issuerFromQueryItems)
        }
    }
}
