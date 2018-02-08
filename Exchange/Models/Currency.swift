//
//  Currency.swift
//  Exchange
//
//  Created by t.galimov on 27/01/2018.
//

import Foundation

enum Currency: String {
    case EUR
    case USD
    case GBP

    var symbol: String {
        switch self {
        case .EUR:
            return "€"
        case .USD:
            return "$"
        case .GBP:
            return "£"
        }
    }

    var displayString: String {
        return rawValue
    }
    
    var identifier: String {
        return rawValue
    }

    init?(identifier: String) {
        self.init(rawValue: identifier)
    }
}
