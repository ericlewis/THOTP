import Foundation
import URL_QueryItem

public extension PasswordProtocol {
    var absoluteURL: URL {
        var components = URLComponents()
        components.scheme = "otpauth"
        components.host = generator.generatorAlgorithm.stringValue
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(key: Key.secret, value: "")
        ]
        
        if let issuer = self.issuer {
            components.host = "\(issuer):\(name)"
            queryItems.append(URLQueryItem(key: Key.name, value: issuer))
        } else {
            components.host = name
        }
        
        if let image = self.image {
            queryItems.append(URLQueryItem(key: Key.image, value: image.absoluteString))
        }
        
        return components.url!
    }
}