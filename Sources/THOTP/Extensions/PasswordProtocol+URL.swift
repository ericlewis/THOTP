import Foundation
import URL_QueryItem
import Base32

// MARK: URL Initializer

public extension PasswordProtocol {
    init(url: URL) throws {
        
        let queryItems = url.queryItems
        
        guard let typeString = url.host else {
            throw OTPError.invalidURL
        }
        
        let splitName = url.path.dropFirst().split(separator: ":")
                
        guard IndexSet([1, 2]).contains(splitName.count) else {
            throw OTPError.invalidURL
        }
        
        guard let name = splitName.last?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            throw OTPError.invalidURL
        }
        
        let issuerSplittedFromName = splitName.count == 2 ? splitName.first?.trimmingCharacters(in: .whitespacesAndNewlines) : nil
        let issuerFromQueryItems = queryItems[Key.issuer]
        
        var issuer: String?
        
        /// The issuer parameter is a string value indicating the provider or service this account is associated with, URL-encoded according to RFC 3986.
        /// If the issuer parameter is absent, issuer information may be taken from the issuer prefix of the label.
        /// If both issuer parameter and issuer label prefix are present, they should be equal.
        /// Source: https://github.com/google/google-authenticator/wiki/Key-Uri-Format#issuer
        switch (issuerSplittedFromName, issuerFromQueryItems) {
        case (.some(let issuerSplittedFromName), .some(let issuerFromQueryItems)):
            guard issuerSplittedFromName == issuerFromQueryItems else {
                throw OTPError.invalidURL
            }
            issuer = issuerSplittedFromName
        case (.some(let issuerSplittedFromName), .none):
            issuer = issuerSplittedFromName
        case (.none, .some(let issuerFromQueryItems)):
            issuer = issuerFromQueryItems
        case (.none, .none):
            break
        }
        
        let imageString = queryItems[Key.image]
        let imageURL = imageString != nil ? URL(string: imageString!) : nil
        
        let algorithm = SupportedHashAlgorithm(rawValue: queryItems[Key.algorithm]?.lowercased() ?? "") ?? .sha1
        
        guard let secret = queryItems[Key.secret]?.base32DecodedData else {
            throw OTPError.invalidURL
        }
        
        var digits = 6
        if let digitsString = queryItems[Key.digits] {
            digits = Int(digitsString) ?? digits
        }
        
        let type: GeneratorAlgorithm
        switch typeString.lowercased() {
        case GeneratorAlgorithm.counter(1).stringValue:
            guard let counterString = queryItems[Key.counter], let counter = UInt64(counterString) else {
                throw OTPError.invalidURL
            }
            
            type = GeneratorAlgorithm.counter(counter)
        case GeneratorAlgorithm.timer(period: 1).stringValue:
            if let periodString = queryItems[Key.period], let period = TimeInterval(periodString) {
                type = GeneratorAlgorithm.timer(period: period)
            } else {
                type = GeneratorAlgorithm.timer(period: 30)
            }
        default:
            throw OTPError.invalidURL
        }
        
        self.init(name: name,
                  issuer: issuer,
                  image: imageURL,
                  generator: try Generator(type: type,
                                           hash: algorithm,
                                           secret: secret,
                                           digits: digits))
    }
}

// MARK: absoluteURL

public extension PasswordProtocol {
    var absoluteURL: URL {
        var components = URLComponents()
        
        components.scheme = "otpauth"
        components.host = generator.generatorAlgorithm.stringValue
        components.path = "/"
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(key: Key.secret, value: generator.secret.base32EncodedString),
            URLQueryItem(key: Key.algorithm, value: generator.hashAlgorithm.rawValue.uppercased()),
            URLQueryItem(key: Key.digits, value: String(generator.digits))
        ]
        
        switch generator.generatorAlgorithm {
        case .counter(let counter):
            queryItems.append(URLQueryItem(key: Key.counter, value: String(counter)))
        case .timer(let period):
            queryItems.append(URLQueryItem(key: Key.period, value: String(period)))
        }
        
        if let issuer = self.issuer {
            components.path += "\(issuer):\(name)"
            queryItems.append(URLQueryItem(key: Key.issuer, value: issuer))
        } else {
            components.path += name
        }
        
        image.map {
            queryItems.append(URLQueryItem(key: Key.image, value: $0.absoluteString))
        }
        
        components.queryItems = queryItems
        
        return components.url!
    }
}
