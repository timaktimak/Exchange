//
//  MoneyAmountTests.swift
//  ExchangeTests
//
//  Created by t.galimov on 03/02/2018.
//

import XCTest
@testable import Exchange

class MoneyAmountTests: XCTestCase {
    
    // Note: should not initialize Decimal with literal float values.
    // Decimal conforms to ExpressibleByFloatLiteral, so
    // a Float or Double is created first, and then a Decimal out of it.
    //
    // E.g.
    // let x: Decimal = 0.12345
    // print(x) // 0.12345000000000002048
    
    // MARK: Helpers
    
    private func checkEquality(_ left: MoneyAmount, _ right: MoneyAmount) {
        XCTAssertEqual(left.majorUnits, right.majorUnits)
        XCTAssertEqual(left.minorUnits, right.minorUnits)
    }
    
    private func checkEquality(decimal: Decimal, amount: MoneyAmount) {
        let left = MoneyAmount(decimal: decimal)
        let right = amount
        checkEquality(left, right)
    }
    
    private func checkAddition(left: MoneyAmount, right: MoneyAmount, result: MoneyAmount) {
        let sum = left + right
        checkEquality(sum, result)
    }
    
    private func checkSubtraction(left: MoneyAmount, right: MoneyAmount, result: MoneyAmount) {
        let difference = left - right
        checkEquality(difference, result)
    }
    
    private func checkMultiplication(left: MoneyAmount, right: Decimal, result: MoneyAmount) {
        let product = left * right
        checkEquality(product, result)
    }
    
    private func checkEqualOperators(_ left: MoneyAmount, _ right: MoneyAmount) {
        XCTAssertTrue(left == right)
        XCTAssertTrue(left <= right)
        XCTAssertTrue(left >= right)
    }
    /// `left` must be smaller than `right`
    private func checkComparison(_ left: MoneyAmount, _ right: MoneyAmount) {
        XCTAssertTrue(left < right)
        XCTAssertTrue(left <= right)
        XCTAssertTrue(right > left)
        XCTAssertTrue(right >= left)
    }
    
    // MARK: Tests
    
    func testInit() {
        checkEquality(0, MoneyAmount(majorUnits: 0, minorUnits: 0))
        checkEquality(2, MoneyAmount(majorUnits: 2, minorUnits: 0))
        do {
            let decimal = Decimal(sign: .plus, exponent: 0, significand: 0)
            let amount = MoneyAmount(majorUnits: 0, minorUnits: 0)
            checkEquality(decimal: decimal, amount: amount)
        }
        do {
            let decimal = Decimal(sign: .plus, exponent: -1, significand: 9)
            let amount = MoneyAmount(majorUnits: 0, minorUnits: 90)
            checkEquality(decimal: decimal, amount: amount)
        }
        do {
            let decimal = Decimal(sign: .plus, exponent: -1, significand: 21)
            let amount = MoneyAmount(majorUnits: 2, minorUnits: 10)
            checkEquality(decimal: decimal, amount: amount)
        }
        do {
            let decimal = Decimal(sign: .plus, exponent: -2, significand: 201)
            let amount = MoneyAmount(majorUnits: 2, minorUnits: 1)
            checkEquality(decimal: decimal, amount: amount)
        }
        do {
            let decimal = Decimal(sign: .plus, exponent: -5, significand: 2_99_999)
            let amount = MoneyAmount(majorUnits: 2, minorUnits: 99)
            checkEquality(decimal: decimal, amount: amount)
        }
    }
    
    func testDecimal() {
        do {
            let amount = MoneyAmount(majorUnits: 0, minorUnits: 1)
            let decimal = Decimal(sign: .plus, exponent: -2, significand: 1)
            XCTAssertEqual(amount.decimal, decimal)
        }
        do {
            let amount = MoneyAmount(majorUnits: 1, minorUnits: 99)
            let decimal = Decimal(sign: .plus, exponent: -2, significand: 199)
            XCTAssertEqual(amount.decimal, decimal)
        }
        do {
            let amount = MoneyAmount(majorUnits: 1, minorUnits: 10)
            let decimal = Decimal(sign: .plus, exponent: -1, significand: 11)
            XCTAssertEqual(amount.decimal, decimal)
        }
        do {
            let amount = MoneyAmount(majorUnits: 2, minorUnits: 0)
            let decimal = Decimal(sign: .plus, exponent: 0, significand: 2)
            XCTAssertEqual(amount.decimal, decimal)
        }
    }

    func testAddition() {
        checkAddition(left: 2, right: 3, result: 5)
        do {
            let left = MoneyAmount(majorUnits: 5, minorUnits: 50)
            let right = MoneyAmount(majorUnits: 4, minorUnits: 40)
            let result = MoneyAmount(majorUnits: 9, minorUnits: 90)
            checkAddition(left: left, right: right, result: result)
        }
        do {
            let left = MoneyAmount(majorUnits: 12, minorUnits: 99)
            let right = MoneyAmount(majorUnits: 1, minorUnits: 4)
            let result = MoneyAmount(majorUnits: 14, minorUnits: 3)
            checkAddition(left: left, right: right, result: result)
        }
    }
    
    func testSubtraction() {
        checkSubtraction(left: 5, right: 3, result: 2)
        checkSubtraction(left: 5, right: 5, result: 0)
        do {
            let left = MoneyAmount(majorUnits: 9, minorUnits: 55)
            let right = MoneyAmount(majorUnits: 3, minorUnits: 22)
            let result = MoneyAmount(majorUnits: 6, minorUnits: 33)
            checkSubtraction(left: left, right: right, result: result)
        }
        do {
            let left = MoneyAmount(majorUnits: 5, minorUnits: 25)
            let right = MoneyAmount(majorUnits: 3, minorUnits: 70)
            let result = MoneyAmount(majorUnits: 1, minorUnits: 55)
            checkSubtraction(left: left, right: right, result: result)
        }
        do {
            let left = MoneyAmount(majorUnits: 5, minorUnits: 0)
            let right = MoneyAmount(majorUnits: 3, minorUnits: 99)
            let result = MoneyAmount(majorUnits: 1, minorUnits: 1)
            checkSubtraction(left: left, right: right, result: result)
        }
    }

    func testMultiplication() {
        checkMultiplication(left: 5, right: 3, result: 15)
        checkMultiplication(left: 5, right: 0, result: 0)
        checkMultiplication(left: 0, right: 3, result: 0)
        checkMultiplication(left: 1, right: 1, result: 1)
        do {
            let left = MoneyAmount(majorUnits: 8, minorUnits: 30)
            let right = Decimal(sign: .plus, exponent: 0, significand: 2)
            let result = MoneyAmount(majorUnits: 16, minorUnits: 60)
            checkMultiplication(left: left, right: right, result: result)
        }
        do {
            let left = MoneyAmount(majorUnits: 4, minorUnits: 30)
            let right = Decimal(sign: .plus, exponent: 0, significand: 4)
            let result = MoneyAmount(majorUnits: 17, minorUnits: 20)
            checkMultiplication(left: left, right: right, result: result)
        }
        do {
            let left = MoneyAmount(majorUnits: 1, minorUnits: 1)
            let right = Decimal(sign: .plus, exponent: 1, significand: 4)
            let result = MoneyAmount(majorUnits: 40, minorUnits: 40)
            checkMultiplication(left: left, right: right, result: result)
        }
        do {
            let left = MoneyAmount(majorUnits: 0, minorUnits: 5)
            let right = Decimal(sign: .plus, exponent: 2, significand: 1)
            let result = MoneyAmount(majorUnits: 5, minorUnits: 0)
            checkMultiplication(left: left, right: right, result: result)
        }
        do {
            // 1.47 * 1.99 = 2.9253
            let left = MoneyAmount(majorUnits: 1, minorUnits: 47)
            let right = Decimal(sign: .plus, exponent: -2, significand: 199)
            let result = MoneyAmount(majorUnits: 2, minorUnits: 92)
            checkMultiplication(left: left, right: right, result: result)
        }
    }
    
    func testEquality() {
        do {
            let left: MoneyAmount = 0
            let right: MoneyAmount = 0
            checkEqualOperators(left, right)
        }
        do {
            let left = MoneyAmount(majorUnits: 4, minorUnits: 34)
            let right = MoneyAmount(majorUnits: 4, minorUnits: 34)
            checkEqualOperators(left, right)
        }
        do {
            let left = MoneyAmount(majorUnits: 0, minorUnits: 99)
            let right = MoneyAmount(majorUnits: 0, minorUnits: 99)
            checkEqualOperators(left, right)
        }
    }
    
    func testInequality() {
        do {
            let left: MoneyAmount = 0
            let right: MoneyAmount = 1
            XCTAssertTrue(left != right)
        }
        do {
            let left: MoneyAmount = 1
            let right: MoneyAmount = 3
            XCTAssertTrue(left != right)
        }
        do {
            let left = MoneyAmount(majorUnits: 4, minorUnits: 33)
            let right = MoneyAmount(majorUnits: 4, minorUnits: 34)
            XCTAssertTrue(left != right)
        }
        do {
            let left = MoneyAmount(majorUnits: 0, minorUnits: 0)
            let right = MoneyAmount(majorUnits: 1, minorUnits: 0)
            XCTAssertTrue(left != right)
        }
    }
    
    func testComparison() {
        do {
            let left: MoneyAmount = 0
            let right: MoneyAmount = 1
            checkComparison(left, right)
        }
        do {
            let left: MoneyAmount = 1
            let right: MoneyAmount = 3
            checkComparison(left, right)
        }
        do {
            let left = MoneyAmount(majorUnits: 0, minorUnits: 0)
            let right = MoneyAmount(majorUnits: 1, minorUnits: 0)
            checkComparison(left, right)
        }
        do {
            let left = MoneyAmount(majorUnits: 0, minorUnits: 0)
            let right = MoneyAmount(majorUnits: 0, minorUnits: 1)
            checkComparison(left, right)
        }
        do {
            let left = MoneyAmount(majorUnits: 2, minorUnits: 98)
            let right = MoneyAmount(majorUnits: 2, minorUnits: 99)
            checkComparison(left, right)
        }
        do {
            let left = MoneyAmount(majorUnits: 2, minorUnits: 45)
            let right = MoneyAmount(majorUnits: 3, minorUnits: 44)
            checkComparison(left, right)
        }
        do {
            let left = MoneyAmount(majorUnits: 2, minorUnits: 99)
            let right = MoneyAmount(majorUnits: 3, minorUnits: 0)
            checkComparison(left, right)
        }
    }
}
