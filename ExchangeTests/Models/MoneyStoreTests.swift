//
//  MoneyStoreTests.swift
//  ExchangeTests
//
//  Created by t.galimov on 06/02/2018.
//

import XCTest
@testable import Exchange

class MoneyStoreTests: XCTestCase {
    
    func test() {
        var store = MoneyStore()
        XCTAssertEqual(0, store.amount(of: .EUR))
        XCTAssertEqual(0, store.amount(of: .USD))
        XCTAssertEqual(0, store.amount(of: .GBP))
        
        try! store.add(amount: 1, of: .EUR)
        XCTAssertEqual(1, store.amount(of: .EUR))
        XCTAssertEqual(0, store.amount(of: .USD))
        XCTAssertEqual(0, store.amount(of: .GBP))
        
        try! store.add(amount: 100, of: .USD)
        XCTAssertEqual(1, store.amount(of: .EUR))
        XCTAssertEqual(100, store.amount(of: .USD))
        XCTAssertEqual(0, store.amount(of: .GBP))
        
        try! store.add(amount: 100, of: .USD)
        XCTAssertEqual(1, store.amount(of: .EUR))
        XCTAssertEqual(200, store.amount(of: .USD))
        XCTAssertEqual(0, store.amount(of: .GBP))
        
        try! store.subtract(amount: 199, of: .USD)
        XCTAssertEqual(1, store.amount(of: .EUR))
        XCTAssertEqual(1, store.amount(of: .USD))
        XCTAssertEqual(0, store.amount(of: .GBP))
        
        try! store.subtract(amount: 0, of: .GBP)
        XCTAssertEqual(1, store.amount(of: .EUR))
        XCTAssertEqual(1, store.amount(of: .USD))
        XCTAssertEqual(0, store.amount(of: .GBP))
        
        do {
            try store.subtract(amount: 2, of: .EUR)
            XCTFail()
        } catch let error {
            let moneyStoreError = error as! MoneyStoreError
            XCTAssertEqual(moneyStoreError, .notEnoughFunds)
        }
    }
}
