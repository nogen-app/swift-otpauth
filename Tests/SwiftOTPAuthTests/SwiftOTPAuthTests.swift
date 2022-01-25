import XCTest
@testable import SwiftOTPAuth

final class SwiftOTPAuthTests: XCTestCase {
	func testFromCompleteURI() throws {
		let otp = try OTPAuth.fromURI("otpauth://totp/ACME%20Co:john@example.com?secret=R33IQKVJ4TKX4PSDWRH7RESGCSPEORRU&issuer=ACME%20Co&algorithm=SHA256&digits=8&period=60")
		
		XCTAssertEqual(otp.otpType, .totp)
		XCTAssertEqual(otp.period, 60)
		XCTAssertEqual(otp.issuer, "ACME Co")
		XCTAssertEqual(otp.algorithm, .SHA256)
		XCTAssertEqual(otp.digits, 8)
		XCTAssertEqual(otp.secret, "R33IQKVJ4TKX4PSDWRH7RESGCSPEORRU")
	}
	
	func testFromURINoPeriod() throws {
		let otp = try OTPAuth.fromURI("otpauth://totp/ACME%20Co:john@example.com?secret=R33IQKVJ4TKX4PSDWRH7RESGCSPEORRU&issuer=ACME%20Co&algorithm=SHA256&digits=8")
		
		XCTAssertEqual(otp.period, 30)
		
		XCTAssertEqual(otp.otpType, .totp)
		XCTAssertEqual(otp.issuer, "ACME Co")
		XCTAssertEqual(otp.algorithm, .SHA256)
		XCTAssertEqual(otp.digits, 8)
		XCTAssertEqual(otp.secret, "R33IQKVJ4TKX4PSDWRH7RESGCSPEORRU")
	}
	
	func testFromURINodigits() throws {
		let otp = try OTPAuth.fromURI("otpauth://totp/ACME%20Co:john@example.com?secret=R33IQKVJ4TKX4PSDWRH7RESGCSPEORRU&issuer=ACME%20Co&algorithm=SHA256&period=30")
		
		XCTAssertEqual(otp.digits, 6)
		
		XCTAssertEqual(otp.otpType, .totp)
		XCTAssertEqual(otp.issuer, "ACME Co")
		XCTAssertEqual(otp.algorithm, .SHA256)
		XCTAssertEqual(otp.period, 30)
		XCTAssertEqual(otp.secret, "R33IQKVJ4TKX4PSDWRH7RESGCSPEORRU")
	}
	
	func testFromURIInvalid() throws {
		XCTAssertThrowsError(try OTPAuth.fromURI("otpauth://totp/ACME%20Co:john@example.com?&issuer=ACME%20Co&algorithm=SHA256&period=30")) { error in
			XCTAssertEqual(error as! OTPError, .noSecret)
		}
	}
	
	
	func testTotpGenerate() throws {
		let otp = OTPAuth(otpType: .totp, secret: "R33IQKVJ4TKX4PSDWRH7RESGCSPEORRU")
		
		var date = DateComponents()
		date.year = 1996
		date.month = 5
		date.day = 18
		date.timeZone = TimeZone.init(abbreviation: "UTC")
		date.hour = 0
		date.minute = 0
		date.second = 0
		
		let userCalendar = Calendar.current
		
		print(String(floor(userCalendar.date(from: date)!.timeIntervalSince1970)))
		
		XCTAssertEqual(otp.generate(userCalendar.date(from: date)!), "660158")
		
		date.hour = 1
		
		XCTAssertNotEqual(otp.generate(userCalendar.date(from: date)!), "660158")
	}
	
	func testHotpGenerate() throws {
		let otp = OTPAuth(otpType: .hotp, secret: "R33IQKVJ4TKX4PSDWRH7RESGCSPEORRU")
		
		XCTAssertEqual(otp.generate(8), "991868")
		
		XCTAssertNotEqual(otp.generate(9), "991868")
		
	}
}
