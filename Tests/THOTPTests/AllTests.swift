import XCTest
import Base32
@testable import THOTP

@available(iOS 13.0, OSX 10.15, watchOS 6.0, tvOS 13.0, *)
final class AllTests: XCTestCase {
    func test_Timer_SHA1_DiffKey() {
        let password = Password(name: "t",
                                issuer: nil,
                                image: nil,
                                generator: try! Generator(type: .timer(period: 1000000000000000), hash: .sha1, secret: Data("a".utf8), digits: 6))
        XCTAssertEqual(password.currentPassword, "413198")
    }
    
    func test_Timer_SHA1() {
        let password = Password(name: "t",
                                issuer: nil,
                                image: nil,
                                generator: try! Generator(type: .timer(period: 1000000000000000), hash: .sha1, secret: Data("".utf8), digits: 6))
        XCTAssertEqual(password.currentPassword, "328482")
    }
    
    func test_Timer_SHA256() {
        let password = Password(name: "t",
                                issuer: nil,
                                image: nil,
                                generator: try! Generator(type: .timer(period: 1000000000000000), hash: .sha256, secret: Data("".utf8), digits: 6))
        XCTAssertEqual(password.currentPassword, "356306")
    }
    
    func test_Timer_SHA512() {
        let password = Password(name: "t",
                                issuer: nil,
                                image: nil,
                                generator: try! Generator(type: .timer(period: 1000000000000000), hash: .sha512, secret: Data("".utf8), digits: 6))
        XCTAssertEqual(password.currentPassword, "674061")
    }
    
    func test_Timer_InvalidPeriod() {
        do {
            let _ = Password(name: "t",
                             issuer: nil,
                             image: nil,
                             generator: try Generator(type: .timer(period: -100000), hash: .sha1, secret: Data("".utf8), digits: 1))
            XCTAssert(false)
        } catch {
            XCTAssert(true)
        }
    }
    
    func test_Counter_SHA1() {
        let password = Password(name: "t",
                                issuer: nil,
                                image: nil,
                                generator: try! Generator(type: .counter(1), hash: .sha1, secret: Data("".utf8), digits: 6))
        XCTAssertEqual(password.currentPassword, "812658")
    }
    
    func test_Counter_SHA256() {
        let password = Password(name: "t",
                                issuer: nil,
                                image: nil,
                                generator: try! Generator(type: .counter(1), hash: .sha256, secret: Data("".utf8), digits: 6))
        XCTAssertEqual(password.currentPassword, "799300")
    }
    
    func test_Counter_SHA512() {
        let password = Password(name: "t",
                                issuer: nil,
                                image: nil,
                                generator: try! Generator(type: .counter(1), hash: .sha512, secret: Data("".utf8), digits: 6))
        XCTAssertEqual(password.currentPassword, "772963")
    }
    
    func test_Counter_InvalidDigits() {
        let password1 = Password(name: "t",
                                 issuer: nil,
                                 image: nil,
                                 generator: try! Generator(type: .counter(1), hash: .sha1, secret: Data("".utf8), digits: 1))
        
        XCTAssertEqual(password1.currentPassword, nil)
    }
    
    func test_Time() {
        do {
            let password = Password(name: "t",
                                        issuer: nil,
                                        image: nil,
                                        generator: try! Generator(type: .timer(period: 1000000000000000), hash: .sha1, secret: Data("".utf8), digits: 6))
            let _ = try password.generator.generate(with: Date.distantPast)
            XCTAssert(false)
        } catch {
            XCTAssert(true)
        }
    }
    
    func test_Equatable_Equal() {
        let password1 = Password(name: "t",
                                 issuer: nil,
                                 image: nil,
                                 generator: try! Generator(type: .counter(1), hash: .sha512, secret: Data("".utf8), digits: 6))
        
        let password2 = Password(name: "t",
                                 issuer: nil,
                                 image: nil,
                                 generator: try! Generator(type: .counter(1), hash: .sha512, secret: Data("".utf8), digits: 6))
        
        XCTAssertEqual(password1, password2)
    }
    
    func test_Equatable_Not_Equal() {
        let password1 = Password(name: "t",
                                 issuer: nil,
                                 image: nil,
                                 generator: try! Generator(type: .counter(1), hash: .sha512, secret: Data("".utf8), digits: 6))
        
        let password2 = Password(name: "t",
                                 issuer: nil,
                                 image: nil,
                                 generator: try! Generator(type: .counter(1), hash: .sha512, secret: Data("a".utf8), digits: 6))
        
        
        XCTAssertNotEqual(password1, password2)
    }
    
    func test_Counter_All_Attributes_absoluteURL() {
    
    let password = Password(name: "john.doe@email.com",
                                 issuer: "ACME Co",
                                 image: URL(string: "https://www.images.com/image.png")!,
                                 generator: try! Generator(type: .timer(period: 30), hash: .sha512, secret: base32DecodeToData("GEZDGNBV")!, digits: 6))
        XCTAssertEqual(password.absoluteURL, URL(string: "otpauth://totp/ACME%20Co:john.doe@email.com?secret=GEZDGNBV&algorithm=SHA512&digits=6&period=30.0&issuer=ACME%20Co&image=https://www.images.com/image.png"))
    }
    
    func test_Counter_absoluteURL() {
    
    let password = Password(name: "test",
                                 issuer: nil,
                                 image: nil,
                                 generator: try! Generator(type: .counter(1), hash: .sha512, secret: base32DecodeToData("GEZDGNBV")!, digits: 6))
                                 
        XCTAssertEqual(password.absoluteURL, URL(string: "otpauth://hotp/test?secret=GEZDGNBV&algorithm=SHA512&digits=6&counter=1"))
    }
    
    
    func test_Timer_absoluteURL() {
    
    let password = Password(name: "test",
                                 issuer: nil,
                                 image: nil,
                                 generator: try! Generator(type: .timer(period: 100000000000000), hash: .sha512, secret: base32DecodeToData("GEZDGNBV")!, digits: 6))
                                 
        XCTAssertEqual(password.absoluteURL, URL(string: "otpauth://totp/test?secret=GEZDGNBV&algorithm=SHA512&digits=6&period=100000000000000.0"))
    }
}
