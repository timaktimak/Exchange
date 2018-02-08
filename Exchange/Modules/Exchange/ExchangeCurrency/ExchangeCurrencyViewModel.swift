//
//  ExchangeCurrencyViewModel.swift
//  Exchange
//
//  Created by t.galimov on 27/01/2018.
//

import Foundation

protocol ExchangeCurrencyViewModelProtocol {
    // UI values
    var currencyString: String { get }
    var amountLeftString: String { get }
    var exchangeRateString: String? { get }
    var exchangeAmountString: String? { get }
    var showInsufficientFunds: Bool { get }
    // input text processing
    func stringByReplacingIn(string: String?, range: NSRange, replacementString: String) -> String
    func addSignIfNeededTo(string: String?) -> String?
    func validate(currentText: String?, resultingText: String?) -> Bool
}

class ExchangeCurrencyViewModel: ExchangeCurrencyViewModelProtocol {
    
    private let maxFractionDigits = 2
    private let maxNonFractionalDigits = 6 // so the maximum enterable amount is 999 999.99
    private let separatorsSet = CharacterSet(charactersIn: ".,")
    private let signsAndSpacesSet = CharacterSet(charactersIn: "+- ")
    
    private let exchangingFrom: Currency
    private let exchangingTo: Currency
    /// Specifies which view is this,
    /// exchanging from, or to.
    private let side: ExchangeSide
    private let exchangeAmountText: String?
    private let model: ExchangeCurrencyModel
   
    init(from: Currency, to: Currency, side: ExchangeSide, exchangeAmountText: String?, model: ExchangeCurrencyModel) {
        self.exchangingFrom = from
        self.exchangingTo = to
        self.side = side
        self.exchangeAmountText = exchangeAmountText
        self.model = model
    }

    // MARK: ExchangeCurrencyViewModelProtocol
    
    var currencyString: String {
        return currency.displayString
    }

    var amountLeftString: String {
        let symbol = currency.symbol
        let amount = FormatHelper.format(moneyAmount: model.amountLeft)
        return "\(symbol)\(amount)"
    }

    var exchangeRateString: String? {
        guard side == .to else { return nil }
        guard exchangingFrom != exchangingTo else { return nil }
        guard let exchangeRate = model.exchangeRate else { return nil }
        let inverseRate = 1 / exchangeRate
        let rate = FormatHelper.format(decimal: inverseRate, precision: .twoDigits)
        let symbolFrom = exchangingFrom.symbol
        let symbolTo = exchangingTo.symbol
        return "\(symbolTo)1 = \(symbolFrom)\(rate)"
    }

    var exchangeAmountString: String? {
        // If the exchangeAmountText was provided, this is the viewModel
        // for the currently edited textField, just set the provided string
        // back into the textField.
        guard exchangeAmountText == nil else { return exchangeAmountText }
        guard exchangingFrom != exchangingTo else { return nil }
        guard model.exchangeAmount > 0 else { return nil }
        let amountString = FormatHelper.format(moneyAmount: model.exchangeAmount)
        return "\(side.sign) \(amountString)"
    }

    var showInsufficientFunds: Bool {
        guard side == .from else { return false }
        return model.amountLeft < model.exchangeAmount
    }
    
    func stringByReplacingIn(string: String?, range: NSRange, replacementString: String) -> String {
        let nsString = (string ?? "") as NSString
        return nsString.replacingCharacters(in: range, with: replacementString)
    }

    func addSignIfNeededTo(string: String?) -> String? {
        guard let string = string else { return nil }
        let noSignString = string.trimmingCharacters(in: signsAndSpacesSet)
        guard noSignString != "" else { return nil }
        return "\(side.sign) \(noSignString)"
    }

    // Only checks for strings that are possible to enter
    // (doesn't check if the string has letters and so on).
    func validate(currentText: String?, resultingText: String?) -> Bool {
        // Always let the user delete symbols, validate only if the user entered a new symbol.
        // One case that I know this will help (not sure this is the best solution, though),
        // is when the user enters 999 999.99 euros, the amount of result in dollars
        // will have too many non-fractional digits, so it would be too bad if the user
        // wouldn't be able to delete any symbols from the dollars text field in this case.
        guard (currentText?.count ?? 0) < (resultingText?.count ?? 0) else { return true }
        guard let string = resultingText?.trimmingCharacters(in: signsAndSpacesSet) else { return true }
        guard hasAtMostOneSeparator(string) else { return false }
        guard doesNotStartWithSeparator(string) else { return false }
        guard notTooManyNonFractionalDigits(string) else { return false }
        guard notTooManyFractionalDigits(string) else { return false }
        return true
    }
    
    // MARK: Private
    
    // has no more than one '.' or ','
    private func hasAtMostOneSeparator(_ string: String) -> Bool {
        let atMostOne = string.countOccurences(from: separatorsSet) <= 1
        return atMostOne
    }
    
    // does not start with '.' or ','
    private func doesNotStartWithSeparator(_ string: String) -> Bool {
        let separatorPosition = string.positionOfFirstCharacter(from: separatorsSet)
        let startsWithSeparator = separatorPosition == 0
        return !startsWithSeparator
    }
    
    // has no more than `maxFractionalDigits` digits before the separator
    private func notTooManyNonFractionalDigits(_ string: String) -> Bool {
        // if the string has not separator, use string.count for the
        // separator position, like the separator is placed right after the string
        let separatorPosition = string.positionOfFirstCharacter(from: separatorsSet) ?? string.count
        let nonFractionalDigitsCount = separatorPosition
        let tooManyNonFractionalDigits = nonFractionalDigitsCount > maxNonFractionalDigits
        return !tooManyNonFractionalDigits
    }
    
    // if has a fractional part, has no more than `maxFractionalDigits` digits after the separator
    private func notTooManyFractionalDigits(_ string: String) -> Bool {
        guard let separatorPosition = string.positionOfFirstCharacter(from: separatorsSet) else { return true }
        let fractionalDigitsCount = string.count - separatorPosition - 1
        let tooManyFractionalDigits = fractionalDigitsCount > maxFractionDigits
        return !tooManyFractionalDigits
    }

    private var currency: Currency {
        switch side {
        case .from:
            return exchangingFrom
        case .to:
            return exchangingTo
        }
    }
}
