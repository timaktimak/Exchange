//
//  ExchangeViewModel.swift
//  Exchange
//
//  Created by t.galimov on 27/01/2018.
//

import Foundation

protocol ExchangeViewModelProtocol {

    // Static info
    
    /// The array of the currencies that can be exchanged.
    var currencies: [Currency] { get }
    
    // Info about the current state
    
    /// The amount of which of the exchange sides
    /// is the user editing, `from` or `to`.
    var currentlyEditedSide: ExchangeSide { get }
    /// Is currently loading exchange rates.
    var isLoading: Bool { get }
    /// Indicates whether the last exchange
    /// rates loading request was unsuccessful
    /// and a new one wasn't started yet.
    var isLoadingError: Bool { get }
    /// Can perform the currency exchange
    /// with current exchange rates
    /// loading situation and inputs.
    var canExchange: Bool { get }
    /// Can be used to update the view based on viewModel's
    /// values on start.
    func currentCurrencyIndexOf(side: ExchangeSide) -> Int
    /// E.g. $1 = £0.69.
    /// If `isExchangingSameCurrency` is `true`, returns `nil`.
    /// If `isLoading` or `isLoadingError` is `true`, returns `nil`.
    var exchangeRateString: String? { get }
    /// E.g. is exchanging from $ to $.
    var isExchangingSameCurrency: Bool { get }
    
    // User actions
    
    /// Must be called when the input field of the side became first responder.
    func startedEditingAmountOf(side: ExchangeSide, text: String?)
    /// Must be called when the user swiped the currencies.
    func transitionedToCurrencyAt(index: Int, side: ExchangeSide)
    /// Must be called when the user changes any of the amounts.
    func editedAmountOf(side: ExchangeSide, text: String?)
    
    // Data retrieval and updating
    
    /// The return value indicates whether the exchange
    /// transaction was successful.
    func performExchange() -> Bool
    /// `completion` is called on the main thread.
    func loadExchangeRates(completion: @escaping (Bool) -> Void)
    
    // Child view models
    
    func currencyViewModelFor(currency: Currency, side: ExchangeSide) -> ExchangeCurrencyViewModelProtocol
}

class ExchangeViewModel: ExchangeViewModelProtocol {
    
    private enum LoadingState {
        /// No call of loadExchangeRates(completion:) was made yet
        case initial
        /// Exchange rates data was recently successfully loaded
        case normal
        /// Exchange rates data request is in progress
        case loading
        /// The last exchange rates request finished with an error
        /// and another one didn't start yet
        case error
    }
    
    private var loadingState: LoadingState = .initial

    private var exchangingFrom: Currency = .GBP
    private var exchangingTo: Currency = .USD
    
    private var amountFrom: MoneyAmount = 0
    private var amountTo: MoneyAmount = 0
    
    /// Which currency input field is the user editing.
    private(set) var currentlyEditedSide: ExchangeSide = .from
    /// Current user input.
    private var currentlyEditedAmountText: String?
    
    var model: ExchangeModelProtocol!

    // MARK: ExchangeViewModelProtocol
    
    let currencies: [Currency] = [.EUR, .GBP, .USD]
    
    var isLoading: Bool {
        return loadingState == .loading
    }
    
    var isLoadingError: Bool {
        return loadingState == .error
    }
    
    var canExchange: Bool {
        guard !isExchangingSameCurrency else { return false }
        guard loadingState == .normal else { return false }
        let nonZeroFrom = amountFrom >= .leastPositiveAmount
        let nonZeroTo = amountTo >= .leastPositiveAmount
        let enoughFunds = model.amountLeft(of: exchangingFrom) >= amountFrom
        return nonZeroFrom && nonZeroTo && enoughFunds
    }

    func performExchange() -> Bool {
        let success = model.performExchange(from: exchangingFrom, amountFrom: amountFrom, to: exchangingTo, amountTo: amountTo)
        if success {
            amountFrom = 0
            amountTo = 0
            currentlyEditedAmountText = nil
        }
        return success
    }

    func loadExchangeRates(completion: @escaping (Bool) -> Void) {
        guard !isLoading else { return }
        loadingState = .loading
        model.loadRates { [weak self] (success) in
            assert(Thread.isMainThread)
            self?.loadingState = success ? .normal : .error
            self?.updateAmounts()
            completion(success)
        }
    }
    
    func currentCurrencyIndexOf(side: ExchangeSide) -> Int {
        switch side {
        case .from:
            guard let index = currencies.index(of: exchangingFrom) else { fatalError() }
            return index
        case .to:
            guard let index = currencies.index(of: exchangingTo) else { fatalError() }
            return index
        }
    }
    
    func currencyViewModelFor(currency: Currency, side: ExchangeSide) -> ExchangeCurrencyViewModelProtocol {
        let from: Currency
        let to: Currency
        let amount: MoneyAmount
        switch side {
        case .from:
            from = currency
            to = exchangingTo
            amount = amountFrom
        default:
            from = exchangingFrom
            to = currency
            amount = amountTo
        }
        let exchangeAmountText = shouldProvideAmountText(for: currency, in: side) ? currentlyEditedAmountText : nil
        let exchangeAmount = shouldProvideAmount(for: currency) ? amount : 0
        let exchangeCurrencyModel = model.exchangeCurrencyModel(from: from, to: to, side: side, exchangeAmount: exchangeAmount)
        let exchangeCurrencyViewModel = ExchangeCurrencyViewModel(from: from,
                                                                  to: to,
                                                                  side: side,
                                                                  exchangeAmountText: exchangeAmountText,
                                                                  model: exchangeCurrencyModel)
        return exchangeCurrencyViewModel
    }
    
    func startedEditingAmountOf(side: ExchangeSide, text: String?) {
        currentlyEditedAmountText = text
        currentlyEditedSide = side
    }
    
    func editedAmountOf(side: ExchangeSide, text: String?) {
        currentlyEditedAmountText = text
        currentlyEditedSide = side
        updateAmounts()
    }

    func transitionedToCurrencyAt(index: Int, side: ExchangeSide) {
        assert(0 <= index && index < currencies.count)
        if currentlyEditedSide == side && index != currentCurrencyIndexOf(side: side) {
            // The swipe of the edited currency was complete,
            // drop the input string, it will get updated from
            // the recalculated amount once the next field
            // becomes first responder.
            currentlyEditedAmountText = nil
        }
        switch side {
        case .from:
            exchangingFrom = currencies[index]
            // use the opposite side, because when the 'from' currency is swiped,
            // we need to recalculate the amountFrom, so from 'to' to 'from'
            amountFrom = calculateExchangeResult(for: amountTo, in: side.opposite)
        case .to:
            exchangingTo = currencies[index]
            amountTo = calculateExchangeResult(for: amountFrom, in: side.opposite)
        }
    }

    var isExchangingSameCurrency: Bool {
        return exchangingFrom == exchangingTo
    }
    
    var exchangeRateString: String? {
        guard !isExchangingSameCurrency else { return nil }
        guard loadingState == .normal else { return nil }
        let rate = model.exchangeRate(from: exchangingFrom, to: exchangingTo)
        let rateFormatted = FormatHelper.format(decimal: rate, precision: .fourDigits)
        let result = "\(exchangingFrom.symbol)1 = \(exchangingTo.symbol)\(rateFormatted)"
        return result
    }
    
    // MARK: Private
    
    /// Update `amountFrom` and `amountTo` based on
    /// `currentlyEditedAmountText`, `currentlyEditedSide`
    /// and rates data.
    private func updateAmounts() {
        let amount = amountFrom(inputString: currentlyEditedAmountText)
        updateAmounts(withEnteredAmount: amount, for: currentlyEditedSide)
    }
    
    private func updateAmounts(withEnteredAmount amount: MoneyAmount, for side: ExchangeSide) {
        let resultAmount = calculateExchangeResult(for: amount, in: side)
        switch side {
        case .from:
            amountFrom = amount
            amountTo = resultAmount
        case .to:
            amountFrom = resultAmount
            amountTo = amount
        }
    }
    
    /// Provide currentlyEditedAmountText only for the currently edited field.
    private func shouldProvideAmountText(for currency: Currency, in side: ExchangeSide) -> Bool {
        guard side == currentlyEditedSide else { return false }
        switch side {
        case .from:
            return currency == exchangingFrom
        case .to:
            return currency == exchangingTo
        }
    }
    
    /// Is currently exchanging from or to this currency.
    private func isCurrentlyExchanging(currency: Currency) -> Bool {
        return currency == exchangingFrom || currency == exchangingTo
    }
    
    private func shouldProvideAmount(for currency: Currency) -> Bool {
        let isExchangingFromThisCurrency = currency == exchangingFrom && currentlyEditedSide == .from
        if isExchangingFromThisCurrency {
            // Always return amount for the exchanged from currency,
            // so that the amount left label gets highlighted
            // even when a loading error happened.
            return true
        }
        let isCurrentlyExchangedCurrency = isCurrentlyExchanging(currency: currency)
        let loadingNormal = loadingState == .normal
        return isCurrentlyExchangedCurrency && loadingNormal
    }
    
    /// The result of exchanging `amount` between `exchangingFrom` and `exchangingTo`
    /// currencies, with the passed `side`. If the exchange rates have not been
    /// loaded successfully, returns 0.
    private func calculateExchangeResult(for amount: MoneyAmount, in side: ExchangeSide) -> MoneyAmount {
        guard model.hasRatesData else { return 0 }
        return model.calculateExchangeAmount(from: exchangingFrom, to: exchangingTo, amount: amount, of: side)
    }

    /// `string` must consist of a sign (optional) and a real number.
    private func amountFrom(inputString string: String?) -> MoneyAmount {
        guard let string = string, string != "" else { return 0 }
        let charactersToTrim = CharacterSet(charactersIn: "+- ")
        let trimmedString = string.trimmingCharacters(in: charactersToTrim)
        // Decimal(string:) constructor works well with decimals with a dot, but not comma.
        // When a comma separated decimal number is passed in, the part after ',' is ignored.
        // Using NumberFormatter is one of the options, but it this case it
        // seems like a bit of an overkill, ended up just replacing commas with dots.
        let separatorCheckedString = trimmedString.replacingOccurrences(of: ",", with: ".")
        guard let decimal = Decimal(string: separatorCheckedString) else { fatalError() }
        let amount = MoneyAmount(decimal: decimal)
        return amount
    }
}
