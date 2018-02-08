//
//  ExchangeViewModelTests.swift
//  ExchangeTests
//
//  Created by t.galimov on 07/02/2018.
//

import XCTest
@testable import Exchange

class ExchangeViewModelTests: XCTestCase {
    
    func testViewModel() {
        let viewModel = ExchangeTestsAssembly.viewModel
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isLoadingError)
        XCTAssertFalse(viewModel.canExchange)
        
        checkCurrentlyEditedSide(viewModel: viewModel)

        let expectation = XCTestExpectation()
        viewModel.loadExchangeRates { success in
            XCTAssertTrue(success)
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertFalse(viewModel.isLoadingError)
            
            self.checkExchangeRateString(viewModel: viewModel)
            self.checkCurrencyViewModels(viewModel: viewModel)
            
            expectation.fulfill()
        }
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertFalse(viewModel.isLoadingError)
        XCTAssertFalse(viewModel.canExchange)
        wait(for: [expectation], timeout: 1)
    }
    
    // Check calls:
    // transtionToExchange
    // startedEditingAmountOf(side:text:)
    // editedAmountOf(side:, text:)
    // currencyViewModelFor(currency:side:)
    
    private func checkCurrencyViewModels(viewModel: ExchangeViewModelProtocol) {
        transtionToExchange(viewModel: viewModel, from: .EUR, to: .USD)
        viewModel.startedEditingAmountOf(side: .to, text: nil)
        viewModel.editedAmountOf(side: .from, text: "- 10")
        do {
            let currencyViewModel = viewModel.currencyViewModelFor(currency: .EUR, side: .from)
            XCTAssertEqual(Currency.EUR.displayString, currencyViewModel.currencyString)
            XCTAssertEqual("- 10", currencyViewModel.exchangeAmountString!)
            XCTAssertEqual(nil, currencyViewModel.exchangeRateString)
        }
        do {
            let currencyViewModel = viewModel.currencyViewModelFor(currency: .USD, side: .to)
            XCTAssertEqual(Currency.USD.displayString, currencyViewModel.currencyString)
            // EUR_USD = 1.2249
            XCTAssertEqual("+ 12.24", currencyViewModel.exchangeAmountString!)
            // 1 / 0.8783 = 0,816393175
            XCTAssertEqual("$1 = €\(0.81)", currencyViewModel.exchangeRateString)
        }
        do {
            let currencyViewModel = viewModel.currencyViewModelFor(currency: .GBP, side: .to)
            XCTAssertEqual(Currency.GBP.displayString, currencyViewModel.currencyString)
            XCTAssertEqual(nil, currencyViewModel.exchangeAmountString)
            // EUR_GBP = 0.8783
            // 1 / 0.8783 = 1.1385631333
            XCTAssertEqual("£1 = €\(1.13)", currencyViewModel.exchangeRateString!)
        }
    }
    
    // Check calls:
    // currentlyEditedSide
    // startedEditingAmountOf(side:text:)
    
    /// Leaves amounts empty.
    private func checkCurrentlyEditedSide(viewModel: ExchangeViewModelProtocol) {
        viewModel.startedEditingAmountOf(side: .from, text: "1")
        XCTAssertEqual(.from, viewModel.currentlyEditedSide)
        viewModel.startedEditingAmountOf(side: .to, text: nil)
        XCTAssertEqual(.to, viewModel.currentlyEditedSide)
        viewModel.startedEditingAmountOf(side: .from, text: nil)
        XCTAssertEqual(.from, viewModel.currentlyEditedSide)
    }
    
    // Check calls:
    // currencies
    // transitionedToCurrencyAt(index:side:)
    // exchangeRateString
    // currentCurrencyIndexOf(side:)
    // isExchangingSameCurrency
    
    private func checkExchangeRateString(viewModel: ExchangeViewModelProtocol) {
        checkExchangeRateString(with: viewModel, from: .EUR, to: .EUR, string: nil)
        XCTAssertTrue(viewModel.isExchangingSameCurrency)
        checkExchangeRateString(with: viewModel, from: .EUR, to: .USD, string: "€1 = $\(EUR_USD)")
        XCTAssertFalse(viewModel.isExchangingSameCurrency)
        // EUR_GBP = 0.8783
        // 1 / 0.8783 = 1.1385631333
        checkExchangeRateString(with: viewModel, from: .GBP, to: .EUR, string: "£1 = €\(1.1385)")
        XCTAssertFalse(viewModel.isExchangingSameCurrency)
    }
    
    private func checkExchangeRateString(with viewModel: ExchangeViewModelProtocol, from: Currency, to: Currency, string: String?) {
        transtionToExchange(viewModel: viewModel, from: from, to: to)
        XCTAssertEqual(string, viewModel.exchangeRateString)
    }
    
    // MARK: Helpers
    
    private func transtionToExchange(viewModel: ExchangeViewModelProtocol, from: Currency, to: Currency) {
        let indexFrom = viewModel.currencies.index(of: from)!
        let indexTo = viewModel.currencies.index(of: to)!
        viewModel.transitionedToCurrencyAt(index: indexFrom, side: .from)
        XCTAssertEqual(indexFrom, viewModel.currentCurrencyIndexOf(side: .from))
        viewModel.transitionedToCurrencyAt(index: indexTo, side: .to)
        XCTAssertEqual(indexTo, viewModel.currentCurrencyIndexOf(side: .to))
    }
}
