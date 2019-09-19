import Foundation
import URL_QueryItem

public extension PasswordProtocol {
    var absoluteURL: URL {
        var components = URLComponents()
        
        components.scheme = "otpauth"
        components.host = generator.generatorAlgorithm.stringValue
        components.path = "/"
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(key: Key.secret, value: "")
        ]
        
        if let issuer = self.issuer {
            components.path += "\(issuer):\(name)"
            queryItems.append(URLQueryItem(key: Key.issuer, value: issuer))
        } else {
            components.path += name
        }
        
        if let image = self.image {
            queryItems.append(URLQueryItem(key: Key.image, value: image.absoluteString))
        }
        
        
        return components.url!
    }
}