//
// MIT License
//
// Copyright (c) 2022 nogen I/S
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import SwiftOTP
import Foundation

public struct OTPAuth {
	public let otpType: OTPType
	public let issuer: String?
	public let label: String
	public let algorithm: OTPAlg
	public let digits: Int
	public let period: Int
	public let secret: String
	public let counter: Int?
	
	public init(otpType: OTPType, issuer: String?, label: String, algorithm: OTPAlg?, digits: Int?, period: Int?, secret: String, counter: Int?) {
		self.otpType = otpType
		self.issuer = issuer
		self.label = label
		self.algorithm = algorithm != nil ? algorithm! : OTPAlg.SHA1
		self.digits = digits != nil ? digits! : 6
		self.period = period != nil ? period! : 30
		self.secret = secret
		self.counter = counter
	}
	
	public init(otpType: OTPType, secret: String) {
		self.otpType = otpType
		self.issuer = ""
		self.label = ""
		self.algorithm = .SHA1
		self.digits = 6
		self.period = 30
		self.secret = secret
		self.counter = nil
	}
	
	public init(otpType: OTPType, secret: String, algorithm: OTPAlg, digits: Int, period: Int) {
		self.otpType = otpType
		self.issuer = ""
		self.label = ""
		self.algorithm = algorithm
		self.digits = digits
		self.period = period
		self.secret = secret
		self.counter = nil
	}
}

extension OTPAuth {
	public func generate() -> String {
		return generate(Date())
	}
	
	public func generate(_ date: Date) -> String {
		let alg: OTPAlgorithm
		
		switch algorithm {
		case .SHA1:
			alg = .sha1
		case .SHA256:
			alg = .sha256
		case .SHA512:
			alg = .sha512
		}
		
		switch otpType {
		case .hotp:
			let generator = HOTP(secret: base32DecodeToData(secret)!, digits: digits, algorithm: alg)
			return generator!.generate(counter: UInt64(counter!))!
		case .totp:
			let generator = TOTP(secret: base32DecodeToData(secret)!, digits: digits, timeInterval: period, algorithm: alg)
			return generator!.generate(time: date)!
		}
	}
}

extension OTPAuth {
	public static func fromURI(_ URI: String) throws -> OTPAuth {
		var counter: Int?
		var algorithm: OTPAlg?
		var digits: Int?
		var period: Int?
		var issuer: String?
		
		let url = URLComponents(url: URL(string: URI)!, resolvingAgainstBaseURL: true)!
		guard url.scheme == "otpauth" else {
			print("Not a valid OTP QR Code")
			throw OTPError.invalidScheme
		}
		
		guard let type = OTPType(rawValue: url.host!) else {
			throw OTPError.invalidType
		}
		
		if let issuerQuery = (url.queryItems!.first(where: { $0.name == "issuer"})) {
			issuer = issuerQuery.value
		}
		
		guard let secretQuery = (url.queryItems!.first(where: { $0.name == "secret"})) else {
			throw OTPError.noSecret
		}
		
		let label = url.path
		
		if let algorithmString = (url.queryItems!.first(where: { $0.name == "algorithm"})) {
			algorithm = OTPAlg(rawValue: algorithmString.value!)
		}
		
		if let digitsString = (url.queryItems!.first(where: { $0.name == "digits"})) {
			guard let convertedDigits = Int(digitsString.value!) else {
				throw OTPError.parsingError
			}
			digits = convertedDigits
		}
		
		if let periodString = (url.queryItems!.first(where: { $0.name == "period"})) {
			guard let convertedPeriod = Int(periodString.value!) else {
				throw OTPError.parsingError
			}
			period = convertedPeriod
		}
		
		if type == OTPType.hotp {
			guard let counterString = (url.queryItems!.first(where: { $0.name == "counter"})) else {
				throw OTPError.parsingError
			}
			guard let convertedCounter = Int(counterString.value!) else {
				throw OTPError.parsingError
			}
			counter = convertedCounter
		} else {
			counter = nil
		}
		
		return OTPAuth(otpType: type, issuer: issuer, label: label, algorithm: algorithm, digits: digits, period: period, secret: secretQuery.value!, counter: counter)
	}
}
