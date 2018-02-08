//
//  ExchangeCurrencyViewModelTests.swift
//  ExchangeTests
//
//  Created by t.galimov on 07/02/2018.
//

import XCTest
@testable import Exchange

class ExchangeCurrencyViewModelTests: XCTestCase {
    
    func testProperties() {
        do {
            let model = ExchangeCurrencyModel(amountLeft: 5, exchangeAmount: 6, exchangeRate: 2)
            let viewModel = ExchangeCurrencyViewModel(from: .EUR, to: .USD, side: .from, exchangeAmountText: nil, model: model)
            XCTAssertEqual("EUR", viewModel.currencyString)
            XCTAssertEqual("€5", viewModel.amountLeftString)
            XCTAssertEqual(nil, viewModel.exchangeRateString)
            XCTAssertEqual("- 6", viewModel.exchangeAmountString)
            XCTAssertTrue(viewModel.showInsufficientFunds)
        }
        do {
            let amount = MoneyAmount(majorUnits: 63, minorUnits: 27)
            let model = ExchangeCurrencyModel(amountLeft: amount, exchangeAmount: 50, exchangeRate: nil)
            let viewModel = ExchangeCurrencyViewModel(from: .USD, to: .GBP, side: .to, exchangeAmountText: "random_text", model: model)
            XCTAssertEqual("GBP", viewModel.currencyString)
            XCTAssertEqual("£63.27", viewModel.amountLeftString)
            XCTAssertEqual(nil, viewModel.exchangeRateString)
            // if the exchangeAmountText is provided, must use it regardless
            // of everything else
            XCTAssertEqual("random_text", viewModel.exchangeAmountString)
            XCTAssertFalse(viewModel.showInsufficientFunds)
        }
        do {
            let model = ExchangeCurrencyModel(amountLeft: 61, exchangeAmount: 10, exchangeRate: 3)
            let viewModel = ExchangeCurrencyViewModel(from: .GBP, to: .EUR, side: .to, exchangeAmountText: nil, model: model)
            XCTAssertEqual("EUR", viewModel.currencyString)
            XCTAssertEqual("€61", viewModel.amountLeftString)
            XCTAssertEqual("€1 = £0.33", viewModel.exchangeRateString)
            XCTAssertEqual("+ 10", viewModel.exchangeAmountString)
            XCTAssertFalse(viewModel.showInsufficientFunds)
        }
    }
    
    private func viewModel(withSide side: ExchangeSide) -> ExchangeCurrencyViewModelProtocol {
        let model = ExchangeCurrencyModel(amountLeft: 0, exchangeAmount: 0, exchangeRate: 0)
        let viewModel = ExchangeCurrencyViewModel(from: .EUR, to: .EUR, side: side, exchangeAmountText: nil, model: model)
        return viewModel
    }
    
    private func someViewModel() -> ExchangeCurrencyViewModelProtocol {
        return viewModel(withSide: .to)
    }
    
    func testStringByReplacing() {
        let viewModel = someViewModel()
        XCTAssertEqual("abc", viewModel.stringByReplacingIn(string: "bc", range: NSMakeRange(0, 0), replacementString: "a"))
        XCTAssertEqual("abc", viewModel.stringByReplacingIn(string: "xbc", range: NSMakeRange(0, 1), replacementString: "a"))
        XCTAssertEqual("bc", viewModel.stringByReplacingIn(string: "xbc", range: NSMakeRange(0, 1), replacementString: ""))
        XCTAssertEqual("x", viewModel.stringByReplacingIn(string: "abcd", range: NSMakeRange(0, 4), replacementString: "x"))
    }
    
    func testValidate() {
        let viewModel = someViewModel()
        XCTAssertTrue(viewModel.validate(currentText: "...", resultingText: nil))
        XCTAssertTrue(viewModel.validate(currentText: nil, resultingText: " - 6.25 "))
        XCTAssertTrue(viewModel.validate(currentText: nil, resultingText: " + 100999,01 "))
        XCTAssertTrue(viewModel.validate(currentText: nil, resultingText: "0.99"))
        XCTAssertTrue(viewModel.validate(currentText: nil, resultingText: "1,00"))
        XCTAssertTrue(viewModel.validate(currentText: nil, resultingText: "123456"))
        XCTAssertTrue(viewModel.validate(currentText: "...", resultingText: "..")) // it's ok to delete
        XCTAssertTrue(viewModel.validate(currentText: "12345678", resultingText: "1234567")) // it's ok to delete
        
        // more than 1 separator
        XCTAssertFalse(viewModel.validate(currentText: nil, resultingText: "1..2"))
        XCTAssertFalse(viewModel.validate(currentText: nil, resultingText: "12,3,1"))
        XCTAssertFalse(viewModel.validate(currentText: nil, resultingText: "22.999,10"))
        XCTAssertFalse(viewModel.validate(currentText: nil, resultingText: "999, 999.5"))
        // starts with separator
        XCTAssertFalse(viewModel.validate(currentText: nil, resultingText: "."))
        XCTAssertFalse(viewModel.validate(currentText: nil, resultingText: ","))
        XCTAssertFalse(viewModel.validate(currentText: nil, resultingText: ".1"))
        XCTAssertFalse(viewModel.validate(currentText: nil, resultingText: ",2"))
        // too many non-fractional
        XCTAssertFalse(viewModel.validate(currentText: nil, resultingText: "1234567"))
        XCTAssertFalse(viewModel.validate(currentText: nil, resultingText: "1234567.9"))
        // too many fractional
        XCTAssertFalse(viewModel.validate(currentText: nil, resultingText: "0.999"))
        XCTAssertFalse(viewModel.validate(currentText: nil, resultingText: "1,001"))
    }
    
    func testAddSignIfNeeded() {
        let viewModel = self.viewModel(withSide: .from)
        XCTAssertEqual(nil, viewModel.addSignIfNeededTo(string: nil))
        XCTAssertEqual(nil, viewModel.addSignIfNeededTo(string: ""))
        XCTAssertEqual(nil, viewModel.addSignIfNeededTo(string: "++++  ----  "))
        XCTAssertEqual("- 5", viewModel.addSignIfNeededTo(string: "+5"))
        XCTAssertEqual("- 2.0", viewModel.addSignIfNeededTo(string: "++++2.0"))
        XCTAssertEqual("- 0", viewModel.addSignIfNeededTo(string: "--+++0"))
        XCTAssertEqual("- 999.99", viewModel.addSignIfNeededTo(string: "-999.99"))
    }
}
