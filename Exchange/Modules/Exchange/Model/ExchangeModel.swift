//
//  ExchangeModel.swift
//  Exchange
//
//  Created by t.galimov on 27/01/2018.
//

import Foundation

/// All of the methods must be called on the main thread.
protocol ExchangeModelProtocol {
    
    // Data
    
    var hasRatesData: Bool { get }
    func amountLeft(of currency: Currency) -> MoneyAmount
    /// What to multiply one `from` by, to get one `to`.
    /// The rates must have been downloaded through the `loadRates(completion:)`.
    /// If the rates have not been successfully downloaded, a fatal error will happen.
    func exchangeRate(from: Currency, to: Currency) -> Decimal
    
    // Actions
    
    /// `completion` is executed on the main thread.
    func loadRates(completion: @escaping (Bool) -> Void)
    /// The return value indicates whether the exchange
    /// transaction was successful.
    /// The rates must have been
    func performExchange(from: Currency, amountFrom: MoneyAmount, to: Currency, amountTo: MoneyAmount) -> Bool
    
    /// Calculates the amount of the other side of the exchange.
    /// So, if `side` == .from, returns amount to,
    /// if `side` == .to returns amount from.
    /// Postcondition: the amountFrom of `from` currency is valid to be exchanged to amountTo of `to` currency.
    func calculateExchangeAmount(from: Currency, to: Currency, amount: MoneyAmount, of side: ExchangeSide) -> MoneyAmount
    
    // Child models
    
    /// Returns a child exchange currency model.
    /// The model will have a `nil` `exchangeRate`, if the
    /// rates have not been downloaded yet.
    func exchangeCurrencyModel(from: Currency, to: Currency, side: ExchangeSide, exchangeAmount: MoneyAmount) -> ExchangeCurrencyModel
}

private func createInitialStore() -> MoneyStore {
    var store = MoneyStore()
    try! store.add(amount: 100, of: .EUR)
    try! store.add(amount: 100, of: .USD)
    try! store.add(amount: 100, of: .GBP)
    return store
}

class ExchangeModel: ExchangeModelProtocol {
    
    var getRatesService: GetExchangeRatesServiceProtocol!

    private let account: MoneyStoreTransactionable
    private var exchangeFromEUR: [Currency: Decimal]
    
    init() {
        let store = createInitialStore()
        self.account = Account(store: store)
        self.exchangeFromEUR = [:]
    }
    
    // MARK: ExchangeModelProtocol
    
    var hasRatesData: Bool {
        return !exchangeFromEUR.isEmpty
    }
    
    func amountLeft(of currency: Currency) -> MoneyAmount {
        return account.store.amount(of: currency)
    }
    
    func exchangeRate(from: Currency, to: Currency) -> Decimal {
        guard let rate = calculateExchangeRate(from: from, to: to) else {
            fatalError("Could not get exchange rate from \(from) to \(to)")
        }
        return rate
    }
    
    func loadRates(completion: @escaping (Bool) -> Void) {
        getRatesService.getRates { [weak self] (rates, error) in
            DispatchQueue.main.async {
                guard let `self` = self else { return }
                guard let rates = rates, error == nil else {
                    self.exchangeFromEUR.removeAll()
                    return completion(false)
                }
                for rate in rates {
                    guard rate.from == .EUR else {
                        assertionFailure()
                        continue
                    }
                    self.exchangeFromEUR[rate.to] = rate.rate
                }
                completion(true)
            }
        }
    }

    func performExchange(from: Currency, amountFrom: MoneyAmount, to: Currency, amountTo: MoneyAmount) -> Bool {
        guard validateExchange(from: from, amountFrom: amountFrom, to: to, amountTo: amountTo) else {
            return false
        }
        let success = account.performTransaction { store in
            try store.subtract(amount: amountFrom, of: from)
            try store.add(amount: amountTo, of: to)
        }
        return success
    }
    
    func calculateExchangeAmount(from: Currency, to: Currency, amount: MoneyAmount, of side: ExchangeSide) -> MoneyAmount {
        switch side {
        case .from:
            let rate = exchangeRate(from: from, to: to)
            return amount * rate
        case .to:
            // So, we need to find the smallest amountFrom, such that
            // amountFrom * rate(from, to) >= amountTo (here, amount argument is amountTo).
            let inverseRate = exchangeRate(from: to, to: from)
            // Get the rounded down result by using the inverse rate.
            var result = amount * inverseRate
            // The following doesn't seem like the best solution, but
            // it works fine and is easy to understand. I can think of an
            // alternative solution that uses division, but it would
            // definitely be less clear and harder to understand.
            
            // While the amount is not big enough, increase it with the smallest possible step.
            while !validateExchange(from: from, amountFrom: result, to: to, amountTo: amount) {
                result += MoneyAmount.leastPositiveAmount
            }
            return result
        }
    }
    
    func exchangeCurrencyModel(from: Currency, to: Currency, side: ExchangeSide, exchangeAmount: MoneyAmount) -> ExchangeCurrencyModel {
        let amount = amountLeft(from: from, to: to, side: side)
        let rate = calculateExchangeRate(from: from, to: to)
        return ExchangeCurrencyModel(amountLeft: amount, exchangeAmount: exchangeAmount, exchangeRate: rate)
    }
    
    // MARK: Private
    
    /// Here an exchange is considered valid, if the user is not getting more money than if
    /// he or she entered `amountFrom` into the from textField.
    private func validateExchange(from: Currency, amountFrom: MoneyAmount, to: Currency, amountTo: MoneyAmount) -> Bool {
        guard hasRatesData else {
            assertionFailure()
            return false
        }
        let rate = exchangeRate(from: from, to: to)
        let regularExchangeResult = amountFrom * rate
        return amountTo <= regularExchangeResult
    }
    
    private func amountLeft(from: Currency, to: Currency, side: ExchangeSide) -> MoneyAmount {
        switch side {
        case .from:
            return amountLeft(of: from)
        case .to:
            return amountLeft(of: to)
        }
    }
    
    private func calculateExchangeRate(from: Currency, to: Currency) -> Decimal? {
        guard from != to else { return 1 }
        if from == .EUR {
            return exchangeFromEUR[to]
        } else if to == .EUR {
            return exchangeFromEUR[from].map { 1 / $0 }
        } else {
            guard let fromToEUR = calculateExchangeRate(from: from, to: .EUR) else { return nil }
            guard let EURToTo = calculateExchangeRate(from: .EUR, to: to) else { return nil }
            return fromToEUR * EURToTo
        }
    }
}
