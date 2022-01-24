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
		
		var date = DateComponents()
		date.year = 1996
		date.month = 5
		date.day = 18
		date.timeZone = TimeZone(abbreviation: "CET")
		date.hour = 0
		date.minute = 0
		date.second = 0
		
		let userCalendar = Calendar.current
		
		XCTAssertEqual(otp.generate(userCalendar.date(from: date)!), "660158")
	}
}
