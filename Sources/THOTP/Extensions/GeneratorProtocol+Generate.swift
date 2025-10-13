import Foundation
import CryptoKit

@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, *)
public extension GeneratorProtocol {
    func generate(with date: borrowing Date) throws(OTPError) -> String {
        let counter = try generatorAlgorithm.value(for: date)

        var bigCounter = counter.bigEndian

        // Generate an HMAC value from the key and counter
        let counterData = Data(bytes: &bigCounter, count: MemoryLayout<UInt64>.size)
        let hash: Data

        let key = SymmetricKey(data: secret)

        func createData(_ ptr: UnsafeRawBufferPointer) -> Data {
            Data(bytes: ptr.baseAddress!, count: hashAlgorithm.length)
        }

        switch hashAlgorithm {
        case .sha1:
            hash = HMAC<Insecure.SHA1>.authenticationCode(for: counterData, using: key).withUnsafeBytes(createData)
        case .sha256:
            hash = HMAC<SHA256>.authenticationCode(for: counterData, using: key).withUnsafeBytes(createData)
        case .sha512:
            hash = HMAC<SHA512>.authenticationCode(for: counterData, using: key).withUnsafeBytes(createData)
        }

        var truncatedHash = hash.withUnsafeBytes { ptr -> UInt32 in
            let offset = ptr.last! & 0x0f
            let truncatedHashPtr = ptr.baseAddress! + Int(offset)
            return truncatedHashPtr.bindMemory(to: UInt32.self, capacity: 1).pointee
        }

        truncatedHash = UInt32(bigEndian: truncatedHash)
        truncatedHash &= 0x7fffffff
        truncatedHash = truncatedHash % UInt32(pow(10, Float(digits)))

        return String(truncatedHash).leftPadding(toLength: digits, withPad: "0")
    }
}

private extension String {
    /// Efficiently pads string from the left with the specified character
    func leftPadding(toLength: Int, withPad: String) -> String {
        let paddingCount = max(0, toLength - count)
        return String(repeating: withPad, count: paddingCount) + self
    }
}
