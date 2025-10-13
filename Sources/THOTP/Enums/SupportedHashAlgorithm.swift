import CryptoKit

/// The available hash functions used for password generation
///
/// ## Supported Hashes
/// These are officially support by google.
/// - **SHA1 (Default)** - Note: SHA1 is cryptographically weak but required for TOTP compatibility
/// - SHA256 (Recommended)
/// - SHA512
@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
public enum SupportedHashAlgorithm: String, Sendable, BitwiseCopyable {
    case sha1, sha256, sha512

    /// The number of bytes in the given hash function's digest.
    public var length: Int {
        switch self {
        case .sha1:
            return Insecure.SHA1.byteCount
        case .sha256:
            return SHA256.byteCount
        case .sha512:
            return SHA512.byteCount
        }
    }
}
