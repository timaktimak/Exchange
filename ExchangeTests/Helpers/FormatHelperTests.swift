//
//  FormatHelperTests.swift
//  ExchangeTests
//
//  Created by t.galimov on 03/02/2018.
//

import XCTest
@testable import Exchange

class FormatHelperTests: XCTestCase {

    // Note: should not initialize Decimal with literal float values.
    // Decimal conforms to ExpressibleByFloatLiteral, so
    // a Float or Double is created first, and then a Decimal out of it.
    //
    // E.g.
    // let x: Decimal = 0.12345
    // print(x) // 0.12345000000000002048
    
    // Tests need to be run for a region with '.'
    // used for the decimal separator.
    
    func testMoneyAmount() {
        do {
            let amount = MoneyAmount(integerLiteral: 0)
            XCTAssertEqual("0", FormatHelper.format(moneyAmount: amount))
        }
        do {
            let amount = MoneyAmount(integerLiteral: 1)
            XCTAssertEqual("1", FormatHelper.format(moneyAmount: amount))
        }
        do {
            let amount = MoneyAmount(majorUnits: 0, minorUnits: 19)
            XCTAssertEqual("0.19", FormatHelper.format(moneyAmount: amount))
        }
        do {
            let amount = MoneyAmount(majorUnits: 1, minorUnits: 10)
            XCTAssertEqual("1.1", FormatHelper.format(moneyAmount: amount))
        }
        do {
            let amount = MoneyAmount(majorUnits: 1, minorUnits: 1)
            XCTAssertEqual("1.01", FormatHelper.format(moneyAmount: amount))
        }
    }
    
    func testTwoDigitsPrecision() {
        do {
            let decimal = Decimal(string: "0.191")!
            XCTAssertEqual("0.19", FormatHelper.format(decimal: decimal, precision: .twoDigits))
        }
        do {
            let decimal = Decimal(string: "10.01")!
            XCTAssertEqual("10.01", FormatHelper.format(decimal: decimal, precision: .twoDigits))
        }
        do {
            let decimal = Decimal(string: "10.10")!
            XCTAssertEqual("10.1", FormatHelper.format(decimal: decimal, precision: .twoDigits))
        }
        do {
            let decimal = Decimal(string: "999999.999999")!
            XCTAssertEqual("999999.99", FormatHelper.format(decimal: decimal, precision: .twoDigits))
        }
    }
    
    func testFourDigitsPrecision() {
        do {
            let decimal = Decimal(string: "0.1915")!
            XCTAssertEqual("0.1915", FormatHelper.format(decimal: decimal, precision: .fourDigits))
        }
        do {
            let decimal = Decimal(string: "0.1900")!
            XCTAssertEqual("0.19", FormatHelper.format(decimal: decimal, precision: .fourDigits))
        }
        do {
            let decimal = Decimal(string: "1.99999")!
            XCTAssertEqual("1.9999", FormatHelper.format(decimal: decimal, precision: .fourDigits))
        }
        do {
            let decimal = Decimal(string: "1.0000999")!
            XCTAssertEqual("1", FormatHelper.format(decimal: decimal, precision: .fourDigits))
        }
        do {
            let decimal = Decimal(string: "999999.99999999")!
            XCTAssertEqual("999999.9999", FormatHelper.format(decimal: decimal, precision: .fourDigits))
        }
    }
}
