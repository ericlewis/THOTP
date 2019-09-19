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
        
        let name = splitName.last!.trimmingCharacters(in: .whitespacesAndNewlines)
        let issuer = splitName.count > 1 ? splitName.first!.trimmingCharacters(in: .whitespacesAndNewlines) : nil
        
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
