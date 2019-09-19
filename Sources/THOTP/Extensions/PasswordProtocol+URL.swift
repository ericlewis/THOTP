import Foundation
import URL_QueryItem
import Base32

public extension PasswordProtocol {
    var absoluteURL: URL {
        var components = URLComponents()
        
        components.scheme = "otpauth"
        components.host = generator.generatorAlgorithm.stringValue
        components.path = "/"
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(key: Key.secret, value: base32Encode(generator.secret)),
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
