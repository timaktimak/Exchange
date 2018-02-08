//
//  XMLRatesParserTests.swift
//  ExchangeTests
//
//  Created by t.galimov on 27/01/2018.
//

import XCTest
@testable import Exchange

class XMLRatesParserTests: XCTestCase {

    let parser = XMLRatesParser()

    func testEmpty() {
        let data = Data()
        let nilRates = parser.parse(data: data)
        XCTAssertNil(nilRates)
    }

    func testValid() {
        let data = Data(xmlFileName: "rates_valid")
        guard let rates = parser.parse(data: data) else { fatalError() }
        XCTAssertEqual(rates.count, 2)
        XCTAssertEqual(rates[0].from, .EUR)
        XCTAssertEqual(rates[0].to, .USD)
        XCTAssertEqual(rates[0].rate, 1.2249)
        XCTAssertEqual(rates[1].from, .EUR)
        XCTAssertEqual(rates[1].to, .GBP)
        XCTAssertEqual(rates[1].rate, 0.87830)
    }

    func testInvalid() {
        let data = Data(xmlFileName: "rates_invalid")
        let rates = parser.parse(data: data)
        XCTAssertNil(rates)
    }
}
