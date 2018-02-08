//
//  Account.swift
//  Exchange
//
//  Created by t.galimov on 27/01/2018.
//

import Foundation

protocol MoneyStoreTransactionable {
    /// Readonly. To add or subtract money, perform a transaction.
    var store: MoneyStore { get }
    /// Performs an atomic transaction. Returns a `Bool` value
    /// indicating whether the transaction was successful.
    func performTransaction(_ block: (inout MoneyStore) throws -> Void) -> Bool
}

class Account: MoneyStoreTransactionable {

    private(set) var store: MoneyStore

    init(store: MoneyStore) {
        self.store = store
    }

    func performTransaction(_ block: (inout MoneyStore) throws -> Void) -> Bool {
        do {
            var newStore = store
            try block(&newStore)
            store = newStore
            return true
        } catch let error {
            print(error)
            return false
        }
    }
}
