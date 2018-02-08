//
//  AccountTests.swift
//  ExchangeTests
//
//  Created by t.galimov on 06/02/2018.
//

import XCTest
@testable import Exchange

class AccountTests: XCTestCase {
    
    func testSuccess() {
        let store = MoneyStore()
        let account = Account(store: store)
        let success = account.performTransaction { store in
            try store.add(amount: 1, of: .USD)
        }
        XCTAssertTrue(success)
        XCTAssertEqual(1, account.store.amount(of: .USD))
        XCTAssertEqual(0, account.store.amount(of: .EUR))
        XCTAssertEqual(0, account.store.amount(of: .GBP))
    }
    
    func testFailure() {
        let store = MoneyStore()
        let account = Account(store: store)
        let success = account.performTransaction { store in
            try store.add(amount: 1, of: .USD)
            try store.subtract(amount: 2, of: .USD)
        }
        XCTAssertFalse(success)
        XCTAssertEqual(0, account.store.amount(of: .USD))
        XCTAssertEqual(0, account.store.amount(of: .EUR))
        XCTAssertEqual(0, account.store.amount(of: .GBP))
    }
}
