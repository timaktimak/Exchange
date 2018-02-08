//
//  ExchangeModelTests.swift
//  ExchangeTests
//
//  Created by t.galimov on 07/02/2018.
//

import XCTest
@testable import Exchange

// from rates_valid.xml
let EUR_USD = Decimal(string: "1.2249")!
let EUR_GBP = Decimal(string: "0.8783")!

class ExchangeModelTests: XCTestCase {
    
    func test() {
        let model = ExchangeTestsAssembly.model
        
        XCTAssertEqual(1, model.exchangeRate(from: .EUR, to: .EUR))
        checkAmounts(model: model, EUR: 100, USD: 100, GBP: 100)
        
        let expectation = XCTestExpectation()
        model.loadRates { success in
            XCTAssertTrue(success)
            
            self.checkExchangeRates(model: model)
            self.checkCurrencyModels(model: model)
            self.checkCalculateExchange(model: model)
            
            let amountToExchange = MoneyAmount(majorUnits: 96, minorUnits: 44)
            do {
                let amountTo = self.checkPerformSuccessfulExchange(model: model, from: .EUR, to: .USD, amountFrom: amountToExchange)
                self.checkAmounts(model: model, EUR: 100 - amountToExchange, USD: 100 + amountTo, GBP: 100)
            }
            
            self.checkCurrencyModels(model: model)
            self.checkNotEnoughFunds(model: model)
            self.checkTooBigAmountTo(model: model)
            
            do {
                let amountFrom = 100 - amountToExchange
                let amountUSDBeforeExchange = model.amountLeft(of: .USD)
                let amountTo = self.checkPerformSuccessfulExchange(model: model, from: .EUR, to: .USD, amountFrom: amountFrom)
                self.checkAmounts(model: model, EUR: 0, USD: amountUSDBeforeExchange + amountTo, GBP: 100)
            }
            self.checkCurrencyModels(model: model)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    /// Returns amountTo.
    private func checkPerformSuccessfulExchange(model: ExchangeModelProtocol,
                                                from: Currency,
                                                to: Currency,
                                                amountFrom: MoneyAmount) -> MoneyAmount {
        let amountTo = amountFrom * model.exchangeRate(from: from, to: to)
        let exchangeSuccess = model.performExchange(from: .EUR, amountFrom: amountFrom, to: .USD, amountTo: amountTo)
        XCTAssertTrue(exchangeSuccess)
        return amountTo
    }
    
    private func checkNotEnoughFunds(model: ExchangeModelProtocol) {
        let amountFrom = model.amountLeft(of: .EUR) + .leastPositiveAmount
        let exchangeSuccess = model.performExchange(from: .EUR, amountFrom: amountFrom, to: .GBP, amountTo: 0)
        XCTAssertFalse(exchangeSuccess)
    }
    
    private func checkTooBigAmountTo(model: ExchangeModelProtocol) {
        let amountFrom = model.amountLeft(of: .EUR)
        let amountTo = (amountFrom * EUR_USD) + .leastPositiveAmount
        let exchangeSuccess = model.performExchange(from: .EUR, amountFrom: amountFrom, to: .USD, amountTo: amountTo)
        XCTAssertFalse(exchangeSuccess)
    }
    
    private func checkAmounts(model: ExchangeModelProtocol, EUR: MoneyAmount, USD: MoneyAmount, GBP: MoneyAmount) {
        XCTAssertEqual(EUR, model.amountLeft(of: .EUR))
        XCTAssertEqual(USD, model.amountLeft(of: .USD))
        XCTAssertEqual(GBP, model.amountLeft(of: .GBP))
    }
    
    private func checkExchangeRates(model: ExchangeModelProtocol) {
        XCTAssertEqual(EUR_USD, model.exchangeRate(from: .EUR, to: .USD))
        XCTAssertEqual(1 / EUR_USD, model.exchangeRate(from: .USD, to: .EUR))
        XCTAssertEqual(EUR_GBP, model.exchangeRate(from: .EUR, to: .GBP))
        XCTAssertEqual(1 / EUR_GBP, model.exchangeRate(from: .GBP, to: .EUR))
        XCTAssertEqual((1 / EUR_USD) * EUR_GBP, model.exchangeRate(from: .USD, to: .GBP))
        XCTAssertEqual((1 / EUR_GBP) * EUR_USD, model.exchangeRate(from: .GBP, to: .USD))
    }
    
    private func checkCurrencyModels(model: ExchangeModelProtocol) {
        let amountEUR = model.amountLeft(of: .EUR)
        let amountGBP = model.amountLeft(of: .GBP)
        let EUR_USD = model.exchangeRate(from: .EUR, to: .USD)
        let USD_GBP = model.exchangeRate(from: .USD, to: .GBP)
        do {
            let exchangeAmount = MoneyAmount(majorUnits: 2, minorUnits: 15)
            let currencyModel = model.exchangeCurrencyModel(from: .EUR, to: .USD, side: .from, exchangeAmount: exchangeAmount)
            checkCurrencyModel(currencyModel, amountLeft: amountEUR, exchangeAmount: exchangeAmount, exchangeRate: EUR_USD)
        }
        do {
            let exchangeAmount = MoneyAmount(majorUnits: 0, minorUnits: 75)
            let currencyModel = model.exchangeCurrencyModel(from: .USD, to: .GBP, side: .to, exchangeAmount: exchangeAmount)
            checkCurrencyModel(currencyModel, amountLeft: amountGBP, exchangeAmount: exchangeAmount, exchangeRate: USD_GBP)
        }
    }
    
    private func checkCurrencyModel(_ model: ExchangeCurrencyModel,
                                    amountLeft: MoneyAmount,
                                    exchangeAmount: MoneyAmount,
                                    exchangeRate: Decimal) {
        XCTAssertEqual(amountLeft, model.amountLeft)
        XCTAssertEqual(exchangeAmount, model.exchangeAmount)
        XCTAssertEqual(exchangeRate, model.exchangeRate)
    }
    
    private func checkCalculateExchange(model: ExchangeModelProtocol) {
        XCTAssertEqual(0, model.calculateExchangeAmount(from: .GBP, to: .EUR, amount: 0, of: .from))
        XCTAssertEqual(0, model.calculateExchangeAmount(from: .GBP, to: .EUR, amount: 0, of: .to))
        do {
            let amount = model.calculateExchangeAmount(from: .EUR, to: .USD, amount: 1, of: .from)
            XCTAssertEqual(amount, MoneyAmount(decimal: EUR_USD))
        }
        do {
            let toAmount = MoneyAmount(majorUnits: 1, minorUnits: 57)
            let amount = model.calculateExchangeAmount(from: .EUR, to: .GBP, amount: toAmount, of: .to)
            // EUR_GBP = 0.8783
            // 1.78 * 0.8783 = 1.563374
            // 1.79 * 0.8783 = 1.572157
            XCTAssertEqual(amount, MoneyAmount(majorUnits: 1, minorUnits: 79))
        }
    }
}
