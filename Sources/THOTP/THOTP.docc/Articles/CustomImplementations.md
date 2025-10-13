# Custom Implementations

Extend THOTP with custom password and generator types.

## Overview

THOTP is built on protocol-oriented design, allowing you to create custom implementations for specialized use cases like Core Data persistence or custom storage backends.

## Custom Password Types

Implement ``PasswordProtocol`` for custom password storage:

```swift
import THOTP
import CoreData

final class ManagedPassword: NSManagedObject, PasswordProtocol {
    @NSManaged var name: String
    @NSManaged var issuer: String?
    @NSManaged var imageURL: URL?
    @NSManaged var secretData: Data
    @NSManaged var digits: Int
    @NSManaged var hashAlgorithmString: String
    @NSManaged var generatorTypeString: String
    @NSManaged var periodOrCounter: Double

    // Computed generator property
    var generator: any GeneratorProtocol {
        let hash = SupportedHashAlgorithm(rawValue: hashAlgorithmString) ?? .sha256

        let type: GeneratorAlgorithm
        if generatorTypeString == "timer" {
            type = .timer(period: periodOrCounter)
        } else {
            type = .counter(UInt64(periodOrCounter))
        }

        return try! Generator(
            type: type,
            hash: hash,
            secret: secretData,
            digits: digits
        )
    }

    var image: URL? {
        imageURL
    }

    // Required initializer
    required init(name: String, issuer: String?, image: URL?, generator: any GeneratorProtocol) {
        let context = PersistenceController.shared.container.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ManagedPassword", in: context)!
        super.init(entity: entity, insertInto: context)

        self.name = name
        self.issuer = issuer
        self.imageURL = image
        self.secretData = generator.secret
        self.digits = generator.digits
        self.hashAlgorithmString = generator.hashAlgorithm.rawValue

        switch generator.generatorAlgorithm {
        case .timer(let period):
            self.generatorTypeString = "timer"
            self.periodOrCounter = period
        case .counter(let value):
            self.generatorTypeString = "counter"
            self.periodOrCounter = Double(value)
        }
    }

    // URL initializers
    required convenience init(url: URL) throws(OTPError) {
        try self.init(url: url, issuerStrategy: .default)
    }

    required convenience init(url: URL, issuerStrategy: IssuerStrategy) throws(OTPError) {
        // Parse URL using Password
        let tempPassword = try Password(url: url, issuerStrategy: issuerStrategy)

        // Initialize with parsed values
        self.init(
            name: tempPassword.name,
            issuer: tempPassword.issuer,
            image: tempPassword.image,
            generator: tempPassword.generator
        )
    }
}
```

### Usage with Core Data

```swift
// Create and save
let generator = try Generator(
    type: .timer(period: 30),
    hash: .sha256,
    secret: secretData,
    digits: 6
)

let password = ManagedPassword(
    name: "user@example.com",
    issuer: "MyApp",
    image: nil,
    generator: generator
)

try context.save()

// Fetch and use
let request = ManagedPassword.fetchRequest()
let passwords = try context.fetch(request)

for password in passwords {
    if let code = password.currentPassword {
        print("\(password.name): \(code)")
    }
}
```

## Custom Generator Types

Implement ``GeneratorProtocol`` for custom generation logic:

```swift
import THOTP
import CryptoKit

struct CustomGenerator: GeneratorProtocol {
    let secret: Data
    let digits: Int
    let generatorAlgorithm: GeneratorAlgorithm
    let hashAlgorithm: SupportedHashAlgorithm

    // Custom field
    let customSalt: Data

    func generate(with date: borrowing Date) throws(OTPError) -> String {
        // Custom generation logic
        let counter = try generatorAlgorithm.value(for: date)

        var bigCounter = counter.bigEndian
        let counterData = Data(bytes: &bigCounter, count: MemoryLayout<UInt64>.size)

        // Mix in custom salt
        let saltedData = secret + customSalt + counterData

        // Use standard HMAC
        let key = SymmetricKey(data: saltedData)
        let hash = HMAC<SHA256>.authenticationCode(for: counterData, using: key)

        // Standard HOTP truncation
        let hashData = Data(hash)
        var truncatedHash = hashData.withUnsafeBytes { ptr -> UInt32 in
            let offset = ptr.last! & 0x0f
            let truncatedHashPtr = ptr.baseAddress! + Int(offset)
            return truncatedHashPtr.bindMemory(to: UInt32.self, capacity: 1).pointee
        }

        truncatedHash = UInt32(bigEndian: truncatedHash)
        truncatedHash &= 0x7fffffff
        truncatedHash = truncatedHash % UInt32(pow(10, Float(digits)))

        let code = String(truncatedHash)
        let paddingCount = max(0, digits - code.count)
        return String(repeating: "0", count: paddingCount) + code
    }
}
```

## Valet Integration

Use [Valet](https://github.com/square/Valet) for secure keychain storage:

```swift
import THOTP
import Valet

struct SecurePasswordStore {
    private let valet = Valet.valet(
        with: Identifier(nonEmpty: "com.myapp.passwords")!,
        accessibility: .whenUnlockedThisDeviceOnly
    )

    func save(_ password: Password) throws {
        guard let url = password.absoluteURL else {
            throw OTPError.invalidURL
        }

        let key = password.name + (password.issuer ?? "")
        let data = url.absoluteString.data(using: .utf8)!

        try valet.setObject(data, forKey: key)
    }

    func load(key: String) throws -> Password? {
        guard let data = try? valet.object(forKey: key),
              let urlString = String(data: data, encoding: .utf8),
              let url = URL(string: urlString) else {
            return nil
        }

        return try Password(url: url)
    }

    func loadAll() throws -> [Password] {
        try valet.allKeys().compactMap { key in
            try? load(key: key)
        }
    }

    func delete(key: String) throws {
        try valet.removeObject(forKey: key)
    }
}
```

## SwiftData Integration

For iOS 17+ apps using SwiftData:

```swift
import SwiftData
import THOTP

@Model
final class StoredPassword {
    var name: String
    var issuer: String?
    var imageURLString: String?
    var secretData: Data
    var digits: Int
    var hashAlgorithmRaw: String
    var generatorType: String
    var periodOrCounter: Double

    init(password: Password) {
        self.name = password.name
        self.issuer = password.issuer
        self.imageURLString = password.image?.absoluteString
        self.secretData = password.generator.secret
        self.digits = password.generator.digits
        self.hashAlgorithmRaw = password.generator.hashAlgorithm.rawValue

        switch password.generator.generatorAlgorithm {
        case .timer(let period):
            self.generatorType = "timer"
            self.periodOrCounter = period
        case .counter(let value):
            self.generatorType = "counter"
            self.periodOrCounter = Double(value)
        }
    }

    func toPassword() throws -> Password {
        let hash = SupportedHashAlgorithm(rawValue: hashAlgorithmRaw) ?? .sha256

        let type: GeneratorAlgorithm
        if generatorType == "timer" {
            type = .timer(period: periodOrCounter)
        } else {
            type = .counter(UInt64(periodOrCounter))
        }

        let generator = try Generator(
            type: type,
            hash: hash,
            secret: secretData,
            digits: digits
        )

        return Password(
            name: name,
            issuer: issuer,
            image: imageURLString.flatMap { URL(string: $0) },
            generator: generator
        )
    }
}
```

## Custom Issuer Strategies

Create custom issuer resolution logic:

```swift
// Prefer longer issuer
let strategy = IssuerStrategy.custom { nameIssuer, queryIssuer in
    guard let name = nameIssuer, let query = queryIssuer else {
        return nameIssuer ?? queryIssuer
    }

    return name.count > query.count ? name : query
}

let password = try Password(url: url, issuerStrategy: strategy)

// Complex business logic
let enterpriseStrategy = IssuerStrategy.custom { nameIssuer, queryIssuer in
    // Your custom validation
    if let name = nameIssuer, isValidEnterpriseIssuer(name) {
        return name
    }

    if let query = queryIssuer, isValidEnterpriseIssuer(query) {
        return query
    }

    throw OTPError.invalidURL
}
```

## Testing Custom Implementations

Test your custom types thoroughly:

```swift
func testManagedPassword() throws {
    let generator = try Generator(
        type: .timer(period: 30),
        hash: .sha256,
        secret: secretData,
        digits: 6
    )

    let password = ManagedPassword(
        name: "test@example.com",
        issuer: "Test",
        image: nil,
        generator: generator
    )

    XCTAssertEqual(password.name, "test@example.com")
    XCTAssertEqual(password.issuer, "Test")
    XCTAssertNotNil(password.currentPassword)

    // Test persistence
    try context.save()

    let fetched = try context.fetch(ManagedPassword.fetchRequest()).first
    XCTAssertEqual(fetched?.name, "test@example.com")
}
```

## Best Practices

1. **Protocol conformance**: Implement all required methods
2. **Error handling**: Properly propagate errors
3. **Thread safety**: Mark concurrent types as `Sendable` when appropriate
4. **Testing**: Thoroughly test custom implementations
5. **Documentation**: Document any deviations from standard behavior
6. **Security**: Handle secrets securely in custom storage

## See Also

- ``PasswordProtocol``
- ``GeneratorProtocol``
- ``Password``
- ``Generator``
- <doc:SecurityBestPractices>
