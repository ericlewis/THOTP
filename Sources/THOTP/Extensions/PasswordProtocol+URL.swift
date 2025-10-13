import Foundation
import URL_QueryItem
import Base32

// MARK: URL Initializer

@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, *)
public extension PasswordProtocol {
    init(url: URL, issuerStrategy: IssuerStrategy) throws(OTPError) {

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

        let issuer = try issuerStrategy.grabIssuer(issuerSplittedFromName: issuerSplittedFromName, issuerFromQueryItems: issuerFromQueryItems)

        let imageURL: URL? = if let imageString = queryItems[Key.image] {
            URL(string: imageString)
        } else {
            nil
        }

        let algorithm = SupportedHashAlgorithm(rawValue: queryItems[Key.algorithm]?.lowercased() ?? "") ?? .sha1

        guard let secret = queryItems[Key.secret]?.base32DecodedData else {
            throw OTPError.invalidURL
        }

        var digits = Generator.defaultDigits
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
                type = GeneratorAlgorithm.timer(period: GeneratorAlgorithm.defaultPeriod)
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

    init(url: URL) throws(OTPError) {
        try self.init(url: url, issuerStrategy: .default)
    }
}

// MARK: absoluteURL

@available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, *)
public extension PasswordProtocol {
    var absoluteURL: URL? {
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

        if let image {
            queryItems.append(URLQueryItem(key: Key.image, value: image.absoluteString))
        }

        components.queryItems = queryItems

        return components.url
    }
}
