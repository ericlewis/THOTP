import Foundation

/// A container for one-time password metadata and generation logic.
///
/// `Password` stores the account information and ``Generator`` needed to produce
/// time-based (TOTP) or counter-based (HOTP) one-time passwords.
///
/// ## Topics
///
/// ### Creating a Password
///
/// - ``init(name:issuer:image:generator:)``
/// - ``init(url:)``
/// - ``init(url:issuerStrategy:)``
///
/// ### Password Properties
///
/// - ``name``
/// - ``issuer``
/// - ``image``
/// - ``generator``
///
/// ### Generating Codes
///
/// - ``currentPassword``
/// - ``timeRemaining``
/// - ``passwordProgress``
///
/// ### URL Generation
///
/// - ``absoluteURL``
///
/// ## Example
///
/// ```swift
/// import THOTP
///
/// // Create a TOTP password
/// let generator = try Generator(
///     type: .timer(period: 30),
///     hash: .sha256,
///     secret: secretData,
///     digits: 6
/// )
///
/// let password = Password(
///     name: "user@example.com",
///     issuer: "MyApp",
///     generator: generator
/// )
///
/// // Generate current code
/// if let code = password.currentPassword {
///     print("Current code: \(code)")
/// }
/// ```
@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, *)
public struct Password: PasswordProtocol, Sendable {

    /// The account name or identifier.
    ///
    /// Typically an email address, username, or account ID.
    ///
    /// ## Example
    /// ```swift
    /// let password = Password(
    ///     name: "user@example.com",  // Email address
    ///     generator: generator
    /// )
    /// ```
    public var name: String

    /// The service or organization name.
    ///
    /// Optional but recommended. Helps users identify accounts in authenticator apps.
    ///
    /// ## Example
    /// ```swift
    /// let password = Password(
    ///     name: "user@example.com",
    ///     issuer: "GitHub",  // Service name
    ///     generator: generator
    /// )
    /// ```
    public var issuer: String?

    /// Optional icon URL for visual identification.
    ///
    /// Not part of the official `otpauth://` spec but supported by some authenticator apps.
    public var image: URL?

    /// The generator that produces one-time passwords.
    ///
    /// Contains the algorithm, secret, and configuration for code generation.
    ///
    /// - SeeAlso: ``Generator``
    public var generator: any GeneratorProtocol

    /// Creates a new password with the specified properties.
    ///
    /// - Parameters:
    ///   - name: The account name or identifier.
    ///   - issuer: Optional service or organization name.
    ///   - image: Optional icon URL.
    ///   - generator: The generator for producing codes.
    ///
    /// ## Example
    /// ```swift
    /// let generator = try Generator(
    ///     type: .timer(period: 30),
    ///     hash: .sha256,
    ///     secret: secretData,
    ///     digits: 6
    /// )
    ///
    /// let password = Password(
    ///     name: "user@example.com",
    ///     issuer: "MyApp",
    ///     generator: generator
    /// )
    /// ```
    public init(name: String, issuer: String? = nil, image: URL? = nil, generator: any GeneratorProtocol) {
        self.name = name
        self.issuer = issuer
        self.image = image
        self.generator = generator
    }
}
