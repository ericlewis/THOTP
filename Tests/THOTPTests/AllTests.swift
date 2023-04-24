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
        XCTAssertEqual(password.currentPassword, "007993")
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
                                 generator: try! Generator(type: .counter(1), hash: .sha512, secret: "GEZDGNBV".base32DecodedData!, digits: 6))
                                 
        XCTAssertEqual(password.absoluteURL, URL(string: "otpauth://hotp/test?secret=GEZDGNBV&algorithm=SHA512&digits=6&counter=1"))
    }
    
    
    func test_Timer_absoluteURL() {
    
    let password = Password(name: "test",
                                 issuer: nil,
                                 image: nil,
                                 generator: try! Generator(type: .timer(period: 100000000000000), hash: .sha512, secret: base32DecodeToData("GEZDGNBV")!, digits: 6))
                                 
        XCTAssertEqual(password.absoluteURL, URL(string: "otpauth://totp/test?secret=GEZDGNBV&algorithm=SHA512&digits=6&period=100000000000000.0"))
    }
    
    func test_Timer_URL_Init_All() {
        do {
            let password = Password(name: "john.doe@email.com",
                                         issuer: "ACME Co",
                                         image: URL(string: "https://www.images.com/image.png")!,
                                         generator: try! Generator(type: .timer(period: 30), hash: .sha512, secret: "GEZDGNBV".base32DecodedData!, digits: 6))
            
            let subject = try Password(url: URL(string: "otpauth://totp/ACME%20Co:john.doe@email.com?secret=GEZDGNBV&algorithm=SHA512&digits=6&period=30.0&issuer=ACME%20Co&image=https://www.images.com/image.png")!)
            XCTAssertEqual(password, subject)
        } catch {
            XCTAssert(false)
        }
    }
    
    func test_Timer_URL_Init_Some() {
        do {
            let password = Password(name: "john.doe@email.com",
                                         issuer: nil,
                                         image: nil,
                                         generator: try! Generator(type: .timer(period: 30), hash: .sha512, secret: "GEZDGNBV".base32DecodedData!, digits: 6))
            
            let subject = try Password(url: URL(string: "otpauth://totp/john.doe@email.com?secret=GEZDGNBV&algorithm=SHA512&digits=6&period=30.0")!)
            XCTAssertEqual(password, subject)
        } catch {
            XCTAssert(false)
        }
    }
    
    func test_Counter_URL_Init_All() {
        do {
            let password = Password(name: "john.doe@email.com",
                                         issuer: "ACME Co",
                                         image: URL(string: "https://www.images.com/image.png")!,
                                         generator: try! Generator(type: .counter(1), hash: .sha512, secret: "GEZDGNBV".base32DecodedData!, digits: 6))
            
            let subject = try Password(url: URL(string: "otpauth://hotp/ACME%20Co:john.doe@email.com?secret=GEZDGNBV&algorithm=SHA512&digits=6&counter=1&issuer=ACME%20Co&image=https://www.images.com/image.png")!)
            XCTAssertEqual(password, subject)
        } catch {
            XCTAssert(false)
        }
    }
    
    func test_Counter_URL_Init_Some() {
        do {
            let password = Password(name: "john.doe@email.com",
                                         issuer: nil,
                                         image: nil,
                                         generator: try! Generator(type: .counter(1), hash: .sha512, secret: "GEZDGNBV".base32DecodedData!, digits: 6))
            
            let subject = try Password(url: URL(string: "otpauth://hotp/john.doe@email.com?secret=GEZDGNBV&algorithm=SHA512&digits=6&counter=1")!)
            XCTAssertEqual(password, subject)
        } catch {
            XCTAssert(false)
        }
    }
    
    func test_Counter_URL_Init_MissingIssuer_In_Name() {
        do {
            let password = Password(name: "john.doe@email.com",
                                         issuer: "ACME Co",
                                         image: nil,
                                         generator: try! Generator(type: .counter(1), hash: .sha512, secret: "GEZDGNBV".base32DecodedData!, digits: 6))
            
            let subject = try Password(url: URL(string: "otpauth://hotp/ACME%20Co:john.doe@email.com?secret=GEZDGNBV&algorithm=SHA512&digits=6&counter=1")!)
            XCTAssertEqual(password, subject)
        } catch {
            XCTAssert(false)
        }
    }
    
    func test_Counter_URL_Init_MissingIssuer_In_Query() {
        do {
            let password = Password(name: "john.doe@email.com",
                                         issuer: "ACME Co",
                                         image: nil,
                                         generator: try! Generator(type: .counter(1), hash: .sha512, secret: "GEZDGNBV".base32DecodedData!, digits: 6))
            
            let subject = try Password(url: URL(string: "otpauth://hotp/john.doe@email.com?secret=GEZDGNBV&algorithm=SHA512&digits=6&counter=1&issuer=ACME%20Co")!)
            XCTAssertEqual(password, subject)
        } catch {
            XCTAssert(false)
        }
    }
    
    func test_Counter_URL_Init_UnequalIssuer() {
        do {
            let _ = try Password(url: URL(string: "otpauth://hotp/ACME%20Com:john.doe@email.com?secret=GEZDGNBV&algorithm=SHA512&digits=6&counter=1&issuer=ACME%20Co")!)
            XCTAssert(false)
        } catch {
            XCTAssert(true)
        }
    }
    
    func test_Counter_URL_Init_InvalidType() {
        do {
            let _ = try Password(url: URL(string: "otpauth://asdfasdf/john.doe@email.com?secret=GEZDGNBV&algorithm=SHA512&digits=6&counter=1")!)
            XCTAssert(false)
        } catch {
            XCTAssert(true)
        }
    }
    
    func test_Counter_URL_Init_InvalidDigits() {
        do {
            let subject = try Password(url: URL(string: "otpauth://hotp/john.doe@email.com?secret=GEZDGNBV&algorithm=SHA512&digits=A&counter=1")!)
            XCTAssertEqual(subject.generator.digits, 6)
        } catch {
            XCTAssert(false)
        }
    }
    
    func test_Counter_URL_Init_InvalidCounter() {
        do {
            let _ = try Password(url: URL(string: "otpauth://hotp/john.doe@email.com?secret=GEZDGNBV&algorithm=SHA512&digits=6&counter=A")!)
            XCTAssert(false)
        } catch {
            XCTAssert(true)
        }
    }
    
    func test_Counter_URL_Init_MissingSecret() {
        do {
            let _ = try Password(url: URL(string: "otpauth://hotp/john.doe@email.com?algorithm=SHA512&digits=6&counter=1")!)
            XCTAssert(false)
        } catch {
            XCTAssert(true)
        }
    }
    
    func test_Timer_URL_Init_NoSpecifiedPeriod() {
        do {
            let subject = try Password(url: URL(string: "otpauth://totp/john.doe@email.com?secret=GEZDGNBV&algorithm=SHA512&digits=6")!)
            switch subject.generator.generatorAlgorithm {
            case .timer(let period):
                XCTAssertEqual(period, 30)
            default:
                XCTAssert(false)
            }
        } catch {
            XCTAssert(false)
        }
    }
    
    func test_Timer_URL_Init_InvalidPeriod() {
        do {
            let subject = try Password(url: URL(string: "otpauth://totp/john.doe@email.com?secret=GEZDGNBV&algorithm=SHA512&digits=6&period=A")!)
            switch subject.generator.generatorAlgorithm {

                        case .timer(let period):
            XCTAssertEqual(period, 30)
        default:
            XCTAssert(false)
        }
        } catch {
            XCTAssert(false)
        }
    }
    
    func test_Timer_URL_Init_InvalidHashAlgo() {
        do {
            let subject = try Password(url: URL(string: "otpauth://hotp/john.doe@email.com?secret=GEZDGNBV&algorithm=a&digits=6&counter=1")!)
            XCTAssertEqual(subject.generator.hashAlgorithm, .sha1)
        } catch {
            XCTAssert(false)
        }
    }
    
    func test_Timer_URL_Init_MissingHashAlgo() {
        do {
            let subject = try Password(url: URL(string: "otpauth://hotp/john.doe@email.com?secret=GEZDGNBV&digits=6&counter=1")!)
            XCTAssertEqual(subject.generator.hashAlgorithm, .sha1)
        } catch {
            XCTAssert(false)
        }
    }
    
    func test_Timer_URL_Init_MissingType() {
        do {
            let _ = try Password(url: URL(string: "otpauth://")!)
            XCTAssert(false)
        } catch {
            XCTAssert(true)
        }
    }
}
