//
//  DecimalExtensionsTests.swift
//  ExchangeTests
//
//  Created by t.galimov on 04/02/2018.
//

import XCTest
@testable import Exchange

class DecimalExtensionsTests: XCTestCase {
    
    // Note: should not initialize Decimal with literal float values.
    // Decimal conforms to ExpressibleByFloatLiteral, so
    // a Float or Double is created first, and then a Decimal out of it.
    //
    // E.g.
    // let x: Decimal = 0.12345
    // print(x) // 0.12345000000000002048
    
    func testIntegerPart() {
        do {
            let decimal: Decimal = 0
            XCTAssertEqual(decimal.integerPart, 0)
        }
        do {
            let decimal: Decimal = 1
            XCTAssertEqual(decimal.integerPart, 1)
        }
        do {
            let decimal = Decimal(string: "10")!
            XCTAssertEqual(decimal.integerPart, 10)
        }
        do {
            let decimal = Decimal(string: "0.1")!
            XCTAssertEqual(decimal.integerPart, 0)
        }
        do {
            let decimal = Decimal(string: "2.25")!
            XCTAssertEqual(decimal.integerPart, 2)
        }
        do {
            let decimal = Decimal(string: "1.999999")!
            XCTAssertEqual(decimal.integerPart, 1)
        }
        do {
            let decimal = Decimal(string: "30.0000")!
            XCTAssertEqual(decimal.integerPart, 30)
        }
        do {
            let decimal = Decimal(string: "9.9537848605577689243027888446215133246")!
            XCTAssertEqual(decimal.integerPart, 9)
        }
    }
    
    func testFractionalPart() {
        do {
            let decimal: Decimal = 0
            XCTAssertEqual(decimal.fractionalPart, 0)
        }
        do {
            let decimal: Decimal = 1
            XCTAssertEqual(decimal.fractionalPart, 0)
        }
        do {
            let decimal    = Decimal(string: "0.1115")!
            let fractional = Decimal(string: "0.1115")!
            XCTAssertEqual(decimal.fractionalPart, fractional)
        }
        do {
            let decimal    = Decimal(string: "2.25")!
            let fractional = Decimal(string: "0.25")!
            XCTAssertEqual(decimal.fractionalPart, fractional)
        }
        do {
            let decimal    = Decimal(string: "1.999999")!
            let fractional = Decimal(string: "0.999999")!
            XCTAssertEqual(decimal.fractionalPart, fractional)
        }
        do {
            let decimal = Decimal(string: "30.0000")!
            XCTAssertEqual(decimal.fractionalPart, 0)
        }
        do {
            let decimal    = Decimal(string: "9.9537848605577689243027888446215133246")!
            let fractional = Decimal(string: "0.9537848605577689243027888446215133246")!
            XCTAssertEqual(decimal.fractionalPart, fractional)
        }
    }
}
