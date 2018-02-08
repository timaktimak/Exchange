//
//  MoneyAmount.swift
//  Exchange
//
//  Created by t.galimov on 03/02/2018.
//

import Foundation

// The approach of using MoneyAmount type is better than just using Decimal everywhere,
// because Decimal stores more than 2 fractional digits and that leads to the
// following potential situation: user has $0.005, and then he exchanges
// $0.015 more. However, in the UI the user will see that he currently has $0.00,
// and is going to get $0.01 more. But after the exchange, the user will
// see that he currently has $0.02 ($0.005 + $0.015). We could, of course,
// drop the fractional part after the second fraction digit of a decimal number
// after each operation, but the following solution is far more clear because it
// encapsulates all of this truncating logic and makes it testable.

/// Represents an amount of money, currency agnostic.
struct MoneyAmount: ExpressibleByIntegerLiteral, Comparable, CustomStringConvertible {
    
    /// The smallest non-zero money amount.
    static let leastPositiveAmount = MoneyAmount(majorUnits: 0, minorUnits: 1)
    
    /// Intergral part. If the amount is 23.67, majorUnits is equal to 23.
    let majorUnits: UInt
    /// Fractional part. Cents. If the amount is 23.67, minorUnits is equal to 67.
    /// 0 <= minorUnits && minorUnits <= 99
    let minorUnits: UInt
    
    init(majorUnits: UInt, minorUnits: UInt) {
        self.majorUnits = majorUnits
        self.minorUnits = minorUnits
    }
    
    /// Only two most significant fractional digits are used,
    /// the rest of the fractional part of the number
    /// is ignored.
    init(decimal: Decimal) {
        majorUnits = UInt(decimal.integerPart)
        let fractionalTimes100 = decimal.fractionalPart * 100
        minorUnits = UInt(fractionalTimes100.integerPart)
    }
    
    var decimal: Decimal {
        return Decimal(majorUnits) + Decimal(minorUnits) / 100
    }
    
    static func +(left: MoneyAmount, right: MoneyAmount) -> MoneyAmount {
        let decimalSum = left.decimal + right.decimal
        return MoneyAmount(decimal: decimalSum)
    }
    
    static func +=(lhs: inout MoneyAmount, rhs: MoneyAmount) {
        lhs = lhs + rhs
    }
    
    /// MoneyAmount can't be negative. Left argument must be greater
    /// than or equal to the right argument.
    static func -(left: MoneyAmount, right: MoneyAmount) -> MoneyAmount {
        let decimalLeft = left.decimal
        let decimalRight = right.decimal
        guard decimalLeft >= decimalRight else { fatalError() }
        let decimalDiff = decimalLeft - decimalRight
        return MoneyAmount(decimal: decimalDiff)
    }
    
    /// `coef` must be non-negative.
    /// Only two most significant fractional digits or the product
    /// are used, the rest of the fractional part of the product
    /// is ignored.
    static func *(amount: MoneyAmount, coef: Decimal) -> MoneyAmount {
        assert(coef >= 0)
        let decimal = amount.decimal * coef
        return MoneyAmount(decimal: decimal)
    }
    
    // MARK: Equatable
    
    static func ==(lhs: MoneyAmount, rhs: MoneyAmount) -> Bool {
        let majorUnitsEqual = lhs.majorUnits == rhs.majorUnits
        let minorUnitsEqual = lhs.minorUnits == rhs.minorUnits
        return majorUnitsEqual && minorUnitsEqual
    }
    
    // MARK: Comparable
    
    public static func <(lhs: MoneyAmount, rhs: MoneyAmount) -> Bool {
        if lhs.majorUnits < rhs.majorUnits {
            return true
        } else if lhs.majorUnits == rhs.majorUnits {
            return lhs.minorUnits < rhs.minorUnits
        } else {
            return false
        }
    }
    
    public static func >(lhs: MoneyAmount, rhs: MoneyAmount) -> Bool {
        if lhs.majorUnits > rhs.majorUnits {
            return true
        } else if lhs.majorUnits == rhs.majorUnits {
            return lhs.minorUnits > rhs.minorUnits
        } else {
            return false
        }
    }
    
    public static func <=(lhs: MoneyAmount, rhs: MoneyAmount) -> Bool {
        return lhs == rhs || lhs < rhs
    }
    
    public static func >=(lhs: MoneyAmount, rhs: MoneyAmount) -> Bool {
        return lhs == rhs || lhs > rhs
    }

    // MARK: ExpressibleByIntegerLiteral
    
    init(integerLiteral value: Int) {
        guard value >= 0 else { fatalError() }
        let decimal = Decimal(value)
        self.init(decimal: decimal)
    }
    
    // MARK: CustomStringConvertible
    
    var description: String {
        return "\(majorUnits).\(minorUnits)"
    }
}
