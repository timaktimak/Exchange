//
//  DecimalExtensions.swift
//  Exchange
//
//  Created by t.galimov on 03/02/2018.
//

import Foundation

extension Decimal {
    
    private static let behavior = NSDecimalNumberHandler(roundingMode: .down,
                                                         scale: 0,
                                                         raiseOnExactness: false,
                                                         raiseOnOverflow: true,
                                                         raiseOnUnderflow: true,
                                                         raiseOnDivideByZero: true)
    /// E.g. 123.456 -> 123
    var integerPart: Int {
        let decimalNumber = NSDecimalNumber(decimal: self)
        let rounded = decimalNumber.rounding(accordingToBehavior: Decimal.behavior)
        return Int(truncating: rounded)
    }
    /// E.g. 123.456 -> 0.456
    var fractionalPart: Decimal {
        return self - Decimal(integerPart)
    }
}
