import XCTest
@testable import SwiftOTPAuth

final class SwiftOTPAuthTests: XCTestCase {
	func testFromURI() throws {
		let otp = try OTPAuth.fromURI("otpauth://totp/ACME%20Co:john@example.com?secret=R33IQKVJ4TKX4PSDWRH7RESGCSPEORRU&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30")
		
		XCTAssertEqual(otp.otpType, .totp)
		XCTAssertEqual(otp.period, 30)
		XCTAssertEqual(otp.issuer, "ACME Co")
		XCTAssertEqual(otp.algorithm, .SHA1)
		XCTAssertEqual(otp.period, 30)
		XCTAssertEqual(otp.secret, "R33IQKVJ4TKX4PSDWRH7RESGCSPEORRU")
	}
	
	func testTotpGenerate() throws {
		let otp = OTPAuth(otpType: .totp, secret: "R33IQKVJ4TKX4PSDWRH7RESGCSPEORRU")
		
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
		let date = formatter.date(from: "1996/05/18 00:00:00")
		
		XCTAssertEqual(otp.generate(date!), "768250")
	}
}
