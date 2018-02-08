//
//  MoneyStore.swift
//  Exchange
//
//  Created by t.galimov on 27/01/2018.
//

import Foundation

enum MoneyStoreError: Error {
    // Note: now MoneyAmount can't be negative, so this error
    // can't be thrown, be let's leave the enum case and >= 0
    // checks, as the MoneyAmount could possibly support negative
    // values in the future.
    case negativeAmount
    case notEnoughFunds
}

struct MoneyStore {

    private var store: [Currency: MoneyAmount] = [:]
    /// Amount must be positive. Can add currency,
    /// even if it hasn't been stored before.
    mutating func add(amount: MoneyAmount, of currency: Currency) throws {
        guard amount >= 0 else {
            throw MoneyStoreError.negativeAmount
        }
        let currenAmount = self.amount(of: currency)
        store[currency] = currenAmount + amount
    }
    /// Amount must be positive. Prior to using this method,
    /// use the `amount(of:)` method to check if
    /// the account has sufficient amount of the currency.
    mutating func subtract(amount: MoneyAmount, of currency: Currency) throws {
        guard amount >= 0 else {
            throw MoneyStoreError.negativeAmount
        }
        let currentAmount = self.amount(of: currency)
        guard currentAmount >= amount else {
            throw MoneyStoreError.notEnoughFunds
        }
        store[currency] = currentAmount - amount
    }

    func amount(of currency: Currency) -> MoneyAmount {
        return store[currency] ?? 0
    }
}
