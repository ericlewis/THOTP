import CryptoKit

/// The available hash functions used for password generation
///
/// ## Supported Hashes
/// These are officially support by google.
/// - **SHA1 (Default)**
/// - SHA256
/// - SHA512
@available(iOS 13.0, OSX 10.15, watchOS 6.0, tvOS 13.0, *)
public enum SupportedHashAlgorithm: String {
    case sha1, sha256, sha512
    
    /// The number of bytes in the given hash function's digest.
    var length: Int {
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
