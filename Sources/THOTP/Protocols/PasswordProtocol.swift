import Foundation

/// A type that can represent one-time password objects
///
/// This object contains the metadata for a Password
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, *)
public protocol PasswordProtocol: Equatable, Sendable {

    /// The account name
    var name: String { get }

    /// The issuer of the one-time password
    ///
    /// Optional, but recommended
    var issuer: String? { get }

    /// An image to associate with a given password
    ///
    /// Not technically part of the Google Authenticator URI [spec](https://github.com/google/google-authenticator/wiki/Key-Uri-Format)
    /// but still useful and supported by other `URI` creators.
    var image: URL? { get }

    /// The generator to be used for creating passwords
    var generator: any GeneratorProtocol { get }

    /// A computed property representing the current password at any given time.
    var currentPassword: String? { get }

    init(name: String, issuer: String?, image: URL?, generator: any GeneratorProtocol)
    init(url: URL) throws(OTPError)
    init(url: URL, issuerStrategy: IssuerStrategy) throws(OTPError)
}
