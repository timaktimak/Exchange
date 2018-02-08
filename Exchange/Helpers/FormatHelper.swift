//
//  FormatHelper.swift
//  Exchange
//
//  Created by t.galimov on 28/01/2018.
//

import Foundation

final class FormatHelper {
    
    enum DecimalPrecision: Int {
        case twoDigits = 2 // used for money amounts, and the rate label for the bottom currency
        case fourDigits = 4 // used for the rate label at the top of the screen
    }
    
    // MARK: Private
    
    private static let twoDigitsFormatter = formatterWith(precision: .twoDigits)
    private static let fourDigitsFormatter = formatterWith(precision: .fourDigits)

    private static let formatters: [DecimalPrecision: NumberFormatter] = [.twoDigits : twoDigitsFormatter,
                                                                          .fourDigits : fourDigitsFormatter]
    
    private static func formatterWith(precision: DecimalPrecision) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.roundingMode = .down
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = precision.rawValue
        return formatter
    }
    
    // MARK: Public

    /// Leaves at most 2 fraction digits, the rest is ignored.
    /// If the result has fraction zeroes at the end, drops them.
    /// `number` must be non-negative.
    static func format(moneyAmount: MoneyAmount) -> String {
        let decimal = moneyAmount.decimal
        // here decimal has at most 2 fractional digits anyway,
        // so precision doesn't influence the result
        return format(decimal: decimal, precision: .twoDigits)
    }

    /// Leaves the specified fraction digits number, the rest is ignored.
    /// If the result has fraction zeroes at the end, drops them.
    /// `number` must be non-negative.
    static func format(decimal: Decimal, precision: DecimalPrecision) -> String {
        assert(decimal >= 0)
        let nsDecimalNumber = decimal as NSDecimalNumber
        guard let formatter = formatters[precision] else { fatalError() }
        guard let result = formatter.string(from: nsDecimalNumber) else {
            assertionFailure()
            return ""
        }
        return result
    }
}
